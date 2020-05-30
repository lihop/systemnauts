extends "res://commander.gd"
# Represents the shell of the player.
# Every action the player takes in the world should be executed through this
# shell (with the exception of if they are at an in game terminal).


# Executes the command at the given path with the arguments passed as an array
# of strings
func execute(path: String, arguments: PoolStringArray, blocking: bool = true):
	run_command(path + " " + arguments.join(" "))