extends Node


func _ready():
	if OS.has_feature("Server"):
		Server.start()
		get_tree().change_scene("res://maps/mothership/mothership.tscn")
	else:
		get_tree().change_scene("res://gui/menus/lobby/lobby.tscn")
