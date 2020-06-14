extends Spatial


export var fast_close := true
var mouse_mode: String = "CAPTURED"


func _ready():
	# Connect the player's dialogue terminal to the output of Godette's shell.
	print("Connecting GodetteShell and DialogueTerminal")
	$GodetteShell.connect("data_received", $Player/HUD/DialogueTerminal, "write")
	$Player/HUD/DialogueTerminal.connect("skip_requested", $Godette, "skip_typing")
	
	yield(_event1(), "completed")
	print("event1 done!")
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	$Player/Yaw/Camera.current = true
#	$Sky_texture.set_time_of_day(6, null)
#
#	yield(get_tree().create_timer(1), "timeout")
#	yield($DialogueTerminal.type("stty rows 12 cols 160\n"), "completed")
#	yield(get_tree().create_timer(0.5), "timeout")
#	yield($DialogueTerminal.type("# Hi cadet"), "completed")
#	yield(get_tree().create_timer(0.5), "timeout")
#	yield($DialogueTerminal.type(", welcome to Cyberspace!\n"), "completed")
#	yield(get_tree().create_timer(0.7), "timeout")
#	yield($DialogueTerminal.type("# I'm godette, I'll be your thread director for this training mission."), "completed")


func _run_script(script):
	for action in script:
		match typeof(action):
			TYPE_STRING:
				yield($Godette.type(action), "completed")
			TYPE_INT:
				yield(get_tree().create_timer(action), "timeout")


func _event1():
	yield(get_tree().create_timer(3), "timeout")
	
	$Player/HUD/DialogueTerminal.incoming_call()
	
	if not $Player/HUD/DialogueTerminal.is_open():
		yield($Player/HUD/DialogueTerminal, "opened")
	
	yield(_run_script([
		"# Hi cadet, welcome to cyberspace!\n",
		0.3,
		"# My name is Godette. I\\'ll be your thread director for this training mission\n.",
		0.5,
		"# First up,",
		0.2,
		" approach the door and I\\'ll unlock it for you.\n"
	]), "completed")
	
	# Consider while loop here so it cheacks the condition each time in case
	# a body other than Player entered the area.
	if not $DoorArea.overlaps_body($Player):
		yield($DoorArea, "body_entered")
	
	_run_script([
		1,
		"# Right now that door is lock. Each room is a directory and you\n",
		"# currently don\\'t have permission to enter than directory.\n",
		5,
		"# This one is one me...\n",
		1,
		"chmod 755 /training/a\n"
	])


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
