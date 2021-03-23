extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Connect_pressed(type := "REMOTE"):
	match type:
		"VBOX":
			Client.join_game("192.168.56.131")
		"REMOTE":
			Client.join_game("ss.nix.nz")

	get_tree().change_scene("res://servers/mothership/mothership.tscn")
