extends Spatial


export var fast_close := true
var mouse_mode: String = "CAPTURED"


func _ready() -> void:
	$Player/Yaw/Camera.current = true
	if fast_close:
		print("** Fast Close enabled in the 's_main.gd' script **")
		print("** 'Esc' to close 'Shift + F1' to release mouse **")
	
	$Terminal.write("Linux is the best operating system in the world!")
	
	$Sky_texture.set_time_of_day(6, null)


func _input(event: InputEvent) -> void:
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


func _on_Sky_texture_sky_updated():
	$Sky_texture.copy_to_environment($WorldEnvironment.environment)
