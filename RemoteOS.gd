extends Node


signal command_completed(exit_code)

var host = "nix" # FIXME: set this somewhere else
var port = 22
var verify_host = true

var _control_path: String = OS.get_user_data_dir() + "/control"
var _thread = Thread.new()


func _ready():
	if not is_connected_to_host():
		OS.execute("ssh", ["-fN", "-o", "ControlMaster=yes", "-S",
				_control_path, "-p", port, host])


func _exit_tree():
	if is_connected_to_host():
		disconnect_from_host()
	
	_thread.wait_to_finish()


func is_connected_to_host() -> int:
	var exit_code = OS.execute("ssh", ["-S", _control_path, "-O", "check", "-"])
	return exit_code == 0


func disconnect_from_host():
	OS.execute("ssh", ["-S", _control_path, "-O", "exit", "-"])


func execute(path: String, arguments: PoolStringArray = [],
		output: Array = [], read_stderr: bool = false):
	_thread.wait_to_finish()
	
	var args = PoolStringArray(["-S", _control_path, "-"])
	args.append(path)
	args.append_array(arguments)
	
	_thread.start(self, "_execute_ssh", [args, output])


func _execute_ssh(userdata):
	var arguments = userdata[0]
	var output = userdata[1]
	
	print(arguments.join(" "))
	var exit_code = OS.execute("ssh", arguments, true, output)
	print("exit code: ", exit_code)
	emit_signal("command_completed", exit_code)
