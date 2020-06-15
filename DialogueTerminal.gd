extends Control
# This node functions like a Dialogue box, except it looks like a terminal
# and can execute shell commands.


signal answered()
signal opened()
signal closed()
signal skip_requested()


enum States {
	CLOSED
	OPEN
}

var _state = States.CLOSED


func _ready():
	_close()
	
	# Stop ringing when opened
	connect("opened", $Ringtone, "stop")


# Deprecated. Use incoming_transmission.
func incoming_call() -> void:
	if _state == States.OPEN:
		# TODO: Play alert notification.
		pass
	else:
		while _state == States.CLOSED:
			$Ringtone.play()
			yield(get_tree().create_timer(2.5), "timeout")


func write(data) -> void:
	$Terminal.write(data)


func is_open() -> bool:
	return _state == States.OPEN


func _input(event):
	# Short press opens the terminal or skips dialogue if it is already open.
	if Input.is_action_just_pressed("ui_toggle_dialogue_terminal"):
		if _state == States.CLOSED:
			_open()
		else:
			emit_signal("skip_requested")
	
	# Long press closes the terminal.
	if InputUtils.is_action_just_long_pressed("ui_toggle_dialogue_terminal"):
		if _state == States.OPEN:
			_close()


func _process(delta):
	pass
	# TODO: Detect long button press in here


func _open() -> void:
	$Terminal.visible = true
	_state = States.OPEN
	emit_signal("opened")


func _close() -> void:
	$Terminal.visible = false
	_state = States.CLOSED
	emit_signal("closed")


func _on_DialogueTerminal_opened():
	pass # Replace with function body.
