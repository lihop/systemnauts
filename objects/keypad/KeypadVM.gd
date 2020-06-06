extends Spatial


func _ready():
	pass


func _on_enter_pressed(player):
	if player.has_method("run_command"):
		var output = []
		var exit_code = yield(player.execute("chmod", [$Keypad.code, $Keypad.path],
				output), "completed")
		
		if exit_code == 0:
			$Keypad.access_granted()
		else:
			$Keypad.access_denied()
