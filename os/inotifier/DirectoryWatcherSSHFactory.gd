extends Inotifier.DirectoryWatcherFactory
class_name DirectoryWatcherSSHFactory
# Factory class for creating DirectoryWatcherSSH instances.
# Requires an SSHConnection node which will be used to connect
# the DirectoryWatcherSSH instances via SSH.


export(NodePath) var ssh_connection

onready var _ssh_connection: SSHConnection = get_node(ssh_connection)


func create_new(directory: String) -> Inotifier.DirectoryWatcher:
	var watcher = preload("res://os/inotifier/DirectoryWatcherSSH.tscn").instance()
	
	watcher.directory = directory
	watcher.ssh_connection = _ssh_connection.get_path()
	
	return watcher
