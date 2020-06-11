extends Inotifier.DirectoryWatcher
class_name DirectoryWatcherSSH


var ssh_connection: NodePath


func _ready():
	var _ssh_stream := preload("res://addons/os_utils/SSHStream.tscn").instance()
	_ssh_stream.command = Inotifier.COMMAND_FORMAT % directory
	print("COMMAND!!!!!: ", _ssh_stream.command)
	_ssh_stream.ssh_connection = ssh_connection
	_ssh_stream.connect("data_received", self, "_parse")
	add_child(_ssh_stream)
