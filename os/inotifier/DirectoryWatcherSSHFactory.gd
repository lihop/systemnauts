extends Inotifier.DirectoryWatcherFactory
class_name DirectoryWatcherSSHFactory
# Factory class for creating DirectoryWatcherSSH instances.
# Requires an SSHConnection node which will be used to connect
# the DirectoryWatcherSSH instances via SSH.


export(NodePath) var ssh_connection

onready var _ssh_connection: SSHConnection = get_node(ssh_connection)


func create_new(directory: String) -> Inotifier.DirectoryWatcher:
	print("creating a new watcher")
	var watcher = preload("res://os/inotifier/DirectoryWatcherSSH.tscn").instance()
	print("new watcher created, going to set params")
	print("in factory ssh_connection param: ", ssh_connection)
	
	watcher.directory = directory
	watcher.ssh_connection = _ssh_connection.get_path()
	print("is absolute: ", _ssh_connection.get_path().is_absolute())
	print("path is: ", _ssh_connection.get_path())
	
	print("params set")
	
	return watcher
