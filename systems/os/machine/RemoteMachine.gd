extends Machine
class_name RemoteMachine


var _ssh_connection: SSHConnection

func _ready():
	_ssh_connection = SSHConnection.new()
	_ssh_connection.user = "root"
	_ssh_connection.host = public_ipv4
	_ssh_connection.port = 22
	_ssh_connection.auto_connect = true
	add_child(_ssh_connection)


func execute(path: String, arguments: PoolStringArray = PoolStringArray([]),
		user: String = "", read_stderr: bool = true) -> ExecResponse:
	# Convert arguments to command that can be executed remotely via ssh.
	var args = PoolStringArray(["-S", _ssh_connection.control_path, "-"])
	
	if not user.empty():
		args.append_array(["runuser", "-u", user, "--"])
	
	args.append("\"'%s %s'\"" % [path, arguments.join(" ")])
	
	return .execute("ssh", args, "", read_stderr)
