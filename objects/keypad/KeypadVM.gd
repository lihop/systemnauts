extends "res://objects/keypad/Keypad.gd"


export(String) var directory


func _ready():
	connect("enter_pressed", self, "_chmod")
	_check_permissions()


func _check_permissions():
	var output = []
	var exit_code = yield(VM.execute("ls",
			["\"-ld %s | awk '{print $1}'\"" % directory], output), "completed")
	
	if exit_code == 0 and output.size() > 0:
		$LabelPermissions.text = output[0]


func _chmod(who, code):
	var user = who.username
	var octal_mode = PoolStringArray(code).join("")
	
	var output = []
	var exit_code = yield(VM.execute("chmod", [octal_mode, directory], output,
			user), "completed")
	
	if exit_code == 0:
		access_granted()
	else:
		access_denied()
	print(output)
	
