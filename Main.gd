extends MarginContainer


const TUTORIAL_SCENE = "res://scenes/tutorial/tutorial.tscn"
const WEB_SERVER_SCENE = "res://scenes/web_server/WebServer.tscn"

export var fast_close := true
var mouse_mode: String = "CAPTURED"

func _on_NewGame_pressed():
	LevelManager.start_level(TUTORIAL_SCENE)


func _input(event):
	if event.is_action_pressed("ui_cancel") and fast_close:
		get_tree().quit() # Quits the game
	
	if event.is_action_pressed("mouse_input") and fast_close:
		match mouse_mode: # Switch statement in GDScript
			"CAPTURED":
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_mode = "VISIBLE"
			"VISIBLE":
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouse_mode = "CAPTURED"
