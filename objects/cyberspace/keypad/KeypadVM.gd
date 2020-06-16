extends "res://objects/keypad/Keypad.gd"


export(NodePath) var directory

onready var _directory: UnixFile = get_node(directory)


func _ready():
	_directory.connect("attributes_changed", self, "_check_permissions")
	connect("enter_pressed", self, "_chmod")
	_check_permissions()


func _check_permissions():
	var output = []
	var exit_code = yield(VM.execute("ls",
			["\"-ld %s | awk '{print $1}'\"" % _directory.absolute_path],
			output), "completed")
	
	if exit_code == 0 and output.size() > 0:
		$LabelPermissions.text = output[0]


func _chmod(who, code):
	var user = who.username
	var octal_mode = PoolStringArray(code).join("")
	
	var output = []
	var exit_code = yield(VM.execute("chmod", [octal_mode, _directory.absolute_path],
			output, user), "completed")
	
	if exit_code == 0:
		access_granted()
	else:
		access_denied()
		who.get_node("HUD").notify(output[0])
	print(output)
	
