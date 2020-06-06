extends Spatial


func _ready() -> void:
	$Player/Yaw/Camera.current = true
	$Sky_texture.set_time_of_day(6, null)


func _start_scene():
	yield($DialogueTerminal.type("stty rows 12 cols 160\n"), "completed")
	yield(get_tree().create_timer(0.5), "timeout")
	yield($DialogueTerminal.type("# Hi cadet"), "completed")
	yield(get_tree().create_timer(0.5), "timeout")
	yield($DialogueTerminal.type(", welcome to Cyberspace!\n"), "completed")
	yield(get_tree().create_timer(0.7), "timeout")
	yield($DialogueTerminal.type("# I'm godette, I'll be your thread director for this training mission."), "completed")
	yield($DialogueTerminal.type("\n\n"), "completed")
	yield($DialogueTerminal.type("type\nsome\nmore\nstuff\nto\nsee\nscroll"), "completed")



func _on_Sky_texture_sky_updated():
	$Sky_texture.copy_to_environment($WorldEnvironment.environment)
