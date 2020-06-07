extends Spatial


export var fast_close := true
var mouse_mode: String = "CAPTURED"


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Player/Yaw/Camera.current = true
	$Sky_texture.set_time_of_day(6, null)
#
#
#func _start_scene():
	yield(get_tree().create_timer(1), "timeout")
	yield($DialogueTerminal.type("stty rows 12 cols 160\n"), "completed")
	yield(get_tree().create_timer(0.5), "timeout")
	yield($DialogueTerminal.type("# Hi cadet"), "completed")
	yield(get_tree().create_timer(0.5), "timeout")
	yield($DialogueTerminal.type(", welcome to Cyberspace!\n"), "completed")
	yield(get_tree().create_timer(0.7), "timeout")
	yield($DialogueTerminal.type("# I'm godette, I'll be your thread director for this training mission."), "completed")


func _on_Sky_texture_sky_updated():
	$Sky_texture.copy_to_environment($WorldEnvironment.environment)


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
