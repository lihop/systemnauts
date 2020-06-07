extends "res://objects/keypad/Keypad.gd"


export(String) var directory


func _ready():
	_check_permissions()


func _check_permissions():
	# TODO: OS execution code.
	var output = []
#	"ls", [
#			"\"-ld /home/leroy/tmp/test/level-1 | awk '{print $1}'\""],
	print("starting slow request")
	_long_running_request()
	print("starting fast request!")
	var exit_code = yield(VM.execute("echo", ["fast"], output), "completed")
	
	print("fastt: ", output)
	
	var permissions = "d---------"
	$LabelPermissions.text = permissions


func _long_running_request():
	var output = []
	yield(VM.execute("sleep", ["\"10 && echo fast\""]), "completed")
	print("slow: ", output)
