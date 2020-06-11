extends Node


signal shell_created(shell)


func _ready():
	if not OS.has_feature("Server"):
		$"Inotifier/DirectoryWatcherSSHFactory/SSHConnection".connect_to_host()


func execute(path: String, arguments: PoolStringArray = PoolStringArray([]),
		output: Array = [], user: String = "") -> int:
	return yield($Executor.execute(path, arguments, output, user), "completed")


func execute_co(path: String, arguments: PoolStringArray = PoolStringArray([]),
		output: Array = []) -> int:
	return -1
