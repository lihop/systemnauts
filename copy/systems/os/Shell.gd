extends Process
class_name Shell


# Reference: https://linux.die.net/man/1/stty
const SpecialCharacters = {
	# Sends an interrupt signal.
	INTR = "\u0003", # ^C
}

const CHAR_INTR = SpecialCharacters.INTR

signal data_received(data)
signal directory_changed(new_directory)

export(NodePath) var shell_stream

var _shell_stream: ShellStream
var _pid_file


func _ready():
	_shell_stream = get_node(shell_stream)
	
	# Get the process id of this shell.
	_set_pid()
	
	# Wait until we have the pid, before connecting the terminal output.
	yield(self, "pid_updated")
	reset()
	_shell_stream.connect("data_received", self, "_on_data_received")


func type(text: String):
	_shell_stream.put_string(text)


func reset():
	# Stop whatever process is currently running in the foreground (if any).
	type(CHAR_INTR)
	# Reset the terminal.
	type("reset\n")


func change_directory(absolute_path: String) -> void:
	type("cd %s\n" % absolute_path)
	var new_directory = yield(get_cwd_async(), "completed")
	emit_signal("directory_changed", new_directory)


func _on_data_received(data: PoolByteArray):
	emit_signal("data_received", data)


# Get the process id of this shell. Currently works in a very roundabout fashion.
func _set_pid():
	_pid_file = "godot-shell-%s-pid" % get_instance_id()
	
	$"/root/VM/Inotifier".add_file_event_handler("/tmp", _pid_file, self,
			"_pid_file_created", Inotifier.EVENT_CREATE)
	
	yield(get_tree().create_timer(1),"timeout")
	_shell_stream.put_string("echo $$ > /tmp/%s\n" % _pid_file)


func _pid_file_created():
	var output = []
	var exit_code = yield(VM.execute("cat", ["/tmp/%s" % _pid_file], output), "completed")
	
	if exit_code == 0:
		print("got pid: ", output)
		pid = int(output[0])
		emit_signal("pid_updated", pid)
	else:
		print("Did not get pid")
		print("error: %d" % exit_code)
		print(output)
		pid = 1
