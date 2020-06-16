extends StaticBody


var open: bool = false
var openable: bool


func _ready():
	Inotifier.add_file_event_handler("/home/leroy/tmp/test", "level-1", self, "_handle_event")
	openable = check_openable()
	open = openable
	$PermissionsLabel.set_text(get_permissions())
	$PermissionsDisplay.set_color(Color.green if openable else Color.red)


func interact(relate):
	if open:
		close()
	else:
		open()


func close():
	$AnimationPlayer.play_backwards("open")
	open = false


func open():
	$AnimationPlayer.play("open")
	open = true


# Check if the door is openable or not.
func check_openable() -> bool:
	var exit_code = OS.execute("test", ["-x", "/home/leroy/tmp/test/level-1"])
	return exit_code == 0

func get_permissions() -> String:
	var output = []
	var exit_code = OS.execute("ls", [
			"\"-ld /home/leroy/tmp/test/level-1 | awk '{print $1}'\""],
			true, output)
	if exit_code == 0:
		return output[0]
	else:
		return "----------"


func _handle_event(event):
	match event:
		Inotifier.EVENT_ATTRIB:
			# Attributes changed. Check if the door should still be open or not.
			var openable = check_openable()
			if not openable and open:
				close()
			elif openable and not open:
				open()
			$PermissionsDisplay.set_text(get_permissions())
			$PermissionsDisplay.set_color(Color.green if openable else Color.red)
