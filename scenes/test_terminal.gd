extends Control

const ESCAPE = 27
const BACKSPACE = 8
const BEEP = 7 
const SPACE = 32
const LEFT_BRACKET = 91
const ENTER = 10
const BACKSPACE_ALT = 127


func _ready():
	connect("resized", self, "resize")
	$ShellHuman.connect("data_received", $Terminal, "write")
	resize()


func resize():
	print("resized")
	$Terminal.rect_size = rect_size
	$Shader.rect_size = rect_size


func _input(event):
	#return
	if event is InputEventKey and event.pressed:
		var data = PoolByteArray([])
		accept_event()
		
		# TODO: Handle more of these.
		if (event.control and event.scancode == KEY_C):
			data.append(3)
		elif event.unicode:
			data.append(event.unicode)
		elif event.scancode == KEY_ENTER:
			data.append(ENTER)
		elif event.scancode == KEY_BACKSPACE:
			data.append(BACKSPACE_ALT)
		elif event.scancode == KEY_ESCAPE:
			data.append(27)
		elif event.scancode == KEY_TAB:
			data.append(9)
		elif OS.get_scancode_string(event.scancode) == "Shift":
			pass
		elif OS.get_scancode_string(event.scancode) == "Control":
			pass
		else:
			pass
			#push_warning('Unhandled input. scancode: ' + str(OS.get_scancode_string(event.scancode)))
		#emit_signal("output", data)
		$ShellHuman/SSHStream.put_data(data)
