extends "res://objects/keypad/Keypad.gd"


export(String) var directory


func _ready():
	_check_permissions()


func _check_permissions():
	var output = []
	print("starting fast request!")
	var exit_code = yield(VM.execute("echo", ["\"first && echo second\""], output), "completed")
	
	for line in output:
		print("line: ", line, " length: ", line.length())
	
	var co = VM.execute_co("while", ["\"true; do date; sleep 1; done\""])
	while co is GDScriptFunctionState and co.is_valid():
		var line = co.resume()
		print("co: ", line)
	
	var permissions = "d---------"
	$LabelPermissions.text = permissions
