extends "res://DialogueTerminal.gd"


func _ready():
	_shell = yield(VM.create_remote_shell("godette"), "completed")
	_shell.connect("received_data", self, "_on_shell_data")
