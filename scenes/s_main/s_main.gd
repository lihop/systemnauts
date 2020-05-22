extends Spatial

#-----------------SCENE--SCRIPT------------------#
#    Close your game faster by clicking 'Esc'    #
#   Change mouse mode by clicking 'Shift + F1'   #
#------------------------------------------------#

export var fast_close := true
var mouse_mode: String = "CAPTURED"
var parser
var testfile: Node

##################################################

func _ready() -> void:
	# Make sure the player is in the starting directory.
	$"/root/PlayerShell".run_command("cd /home/leroy/tmp/test")
	
	# General directory handler
	Inotifier.add_event_handler("/home/leroy/tmp/test", self, "general_dir_handler")
	
	# General file handler
	Inotifier.add_file_event_handler("/home/leroy/tmp/test", "index.html", self, "general_file_handler")
	
	# Specific directory handler
	Inotifier.add_event_handler("/home/leroy/tmp/test", self, "specific_dir_handler", Inotifier.EVENT_CREATE)
	
	# Specific file handler
	Inotifier.add_file_event_handler("/home/leroy/tmp/test", "index.html", self, "specific_file_handler", Inotifier.EVENT_CREATE)
	
	Inotifier.add_file_event_handler("/home/leroy/tmp/test", "index.html", self, "testfile_deleted", Inotifier.EVENT_DELETE)
	Inotifier.add_file_event_handler("/home/leroy/tmp/test", "index.html", self, "testfile_created", Inotifier.EVENT_CREATE)
	
	#$Commander.run_command("cd /home/leroy/tmp/test")
	#$Terminal.connect("output", $Commander, "write")
	$"/root/PlayerShell".connect("data_received", $Terminal, "write")
	#$Terminal.queue_free()
	
	if fast_close:
		print("** Fast Close enabled in the 's_main.gd' script **")
		print("** 'Esc' to close 'Shift + F1' to release mouse **")
	
	testfile = $"index_html".duplicate()


func testfile_deleted():
	print("Delete TestFile!")
	$"index_html".queue_free()


func testfile_created():
	print("Create TestFile!")
	var duplicate = testfile.duplicate()
	duplicate.name = "index_html"
	add_child(duplicate)


func general_dir_handler(file, event):
	return
	#print("general_dir_handler, file: %s, event: %s" % [file, event])

func general_file_handler(event):
	return
	#print("general_file_handler, event: %s" % event)

func specific_dir_handler(file):
	return
	#print("specific_dir_handler, file: %s" % file)

func specific_file_handler():
	return
	#print("specific_file_handler")


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
