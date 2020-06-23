extends Node
class_name SSHConnection


# Path to the ssh executable.
export(String) var ssh_path := "ssh"
export(String) var user := OS.get_environment("USER")
export(String) var host
export(int) var port := 22
# Where to create the socket for this connection.
export(String) var control_path_prefix := "user://"
export(bool) var auto_connect = false
export(bool) var disabled = OS.has_feature("Server")

var control_path
var _streams := []


func _ready():
	if disabled:
		return
	print("starting ssh connection")
	control_path = ProjectSettings.globalize_path("%s/%s-%s-%d" % \
			[control_path_prefix, user, host, port])
	
	if auto_connect:
		connect_to_host()


func _enter_tree():
	if auto_connect:
		connect_to_host()


func connect_to_host() -> int:
	if disabled:
		return 0
	
	if is_connected_to_host():
		return OK
	
	var output = []
	var exit_code = OS.execute(ssh_path, ["-M", "-o", "ControlPersist=yes", "-S",
			control_path, "-p", port, "%s@%s" % [user, host], "true"],
			true, output, true)
	
	if exit_code != 0:
		var message = "" if output.empty() else output[0].trim_suffix("\n")
		push_error("(%d) %s" % [exit_code, message])
		return ERR_CANT_CONNECT
	else:
		return OK


func is_connected_to_host() -> bool:
	var exit_code = OS.execute(ssh_path, ["-S", control_path, "-O", "check", "-"])
	return exit_code == 0


func disconnect_from_host():
	OS.execute(ssh_path, ["-S", control_path, "-O", "exit", "-"])


# Like OS.execute executed on `host` by `user` via SSH.
func execute():
	pass


func _exit_tree():
	disconnect_from_host()
