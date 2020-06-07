extends Node


signal shell_created(shell)


func execute(path: String, arguments: PoolStringArray = PoolStringArray([]),
		output: Array = []) -> int:
	return yield($Executor.execute(path, arguments, output), "completed")


func execute_co(path: String, arguments: PoolStringArray = PoolStringArray([]),
		output: Array = []) -> int:
	return -1
