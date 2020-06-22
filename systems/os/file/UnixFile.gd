extends Node
class_name UnixFile

signal attributes_changed()
# Emitted when the file is created.
signal created()
# Emitted when the file is deleted.
signal deleted()

enum FileTypes {
	REGULAR
	DIRECTORY
	SYMBOLIC_LINK
	FIFO
	SOCKET
	BLOCK_DEVICE
	CHARACTER_DEVICE
}

const FILE_REGULAR = FileTypes.REGULAR
const FILE_DIRECTORY = FileTypes.DIRECTORY
const FILE_SYMBOLIC_LINK = FileTypes.SYMBOLIC_LINK
const FILE_FIFO = FileTypes.FIFO
const FILE_SOCKET = FileTypes.SOCKET
const FILE_BLOCK_DEVICE = FileTypes.BLOCK_DEVICE
const FILE_CHARACTER_DEVICE = FileTypes.CHARACTER_DEVICE

enum Permissions {
	READ = 0b100
	WRITE = 0b010
	EXECUTE = 0b001
}

const PERM_READ = Permissions.READ
const PERM_WRITE = Permissions.WRITE
const PERM_EXECUTE = Permissions.EXECUTE

enum Classes {
	OWNER = 6
	GROUP = 3
	WORLD = 0
}

const CLASS_OWNER = Classes.OWNER
const CLASS_GROUP = Classes.GROUP
const CLASS_WORLD = Classes.WORLD


export(NodePath) var machine = "/root/WorldMachine/machine"
export(String) var absolute_path
export(String) var file_name
export(String) var file_owner
export(String) var file_group
export(String) var file_mode
# If true and the file does not exist, it will be created.
export(bool) var create := false
# If true and another file exists at the same path, it will be deleted and
# replaced with this file.
export(bool) var overwrite := false

var type

onready var _OS = get_node(machine)

func _ready():
	add_to_group("files", true)
	
	if file_name:
		absolute_path = "%s/%s" % [absolute_path, file_name]
	
	if create:
		_create()
	#_ensure_file_exists()
	#_update_file_owner()
	#_update_file_group()
	#_update_file_mode()
	create = false
	overwrite = false


func _update_file_name(path: String):
	var result = yield(_OS.execute("basename", [path]), "completed")
	file_name = result.output[0]
	


func _update_file_attributes(new_attributes = null):
	emit_signal("attributes_changed")


# Returns whether `class` has `permission`.
func check_permission(class_: int, permission: int) -> bool:
	# We use some "clever" bitwise operations here.
	# Reference: https://icarus.cs.weber.edu/~dab/cs1410/textbook/2.Core/bitop_eg.html
	return (("0x" + file_mode).hex_to_int() & permission << class_) > 0


func _file_exists() -> bool:
	var result = yield(_OS.execute("stat", ["-c", "''", absolute_path]), "completed")
	return result.exit_code == 0


func _create() -> int:
	return -1


func _delete() -> int:
	var result = yield(_OS.execute("rm", ["-rf", absolute_path]), "completed")
	
	if result.exit_code == 0:
		return OK
	else:
		push_error(PoolStringArray(result.output).join("\n"))
		return ERR_BUG


func _ensure_file_exists():
	pass
#	var exit_code = yield(VM.execute("stat", [absolute_path]), "completed")
#
#	if exit_code != 0:
#		# File doesn't exist, create it.
#		match type:
#			FILE_REGULAR:
#				# First ensure that the files directory exists.
#				var output = []
#				yield(VM.execute("dirname", [absolute_path], output), "completed")
#				yield(VM.execute("mkdir", ["-p", output[0]]), "completed")
#
#				# Now create the file.
#				yield(VM.execute("touch", [absolute_path]), "completed")
#
#			FILE_DIRECTORY:
#				yield(VM.execute("mkdir", ["-p", absolute_path]), "completed")
#			_:
#				# TODO: create other file types
#				pass


func _update_file_type():
	var output = []
	yield(VM.execute("stat", ["-c", "%F", absolute_path], output), "completed")
	
	match output[0]:
		"regular file", "regular empty file":
			type = FILE_REGULAR
		"directory":
			type = FILE_DIRECTORY
		_:
			# TODO: handle other file types
			pass


# If `file_owner` is not specified, updates it to match the file. Otherwise,
# updates the file to match it.
func _update_file_owner():
	if not file_owner:
		# TODO: Read from file
		pass
	else:
		var output = []
		var exit_code = yield(VM.execute("chown", [file_owner, absolute_path], []), "completed")
		
		if exit_code != 0:
			var message = absolute_path if output.empty() else output[0]
			push_error("Error updating file owner: %s" % message)
		
		emit_signal("attributes_changed")


# If `file_group` is not specified, updates it to match the file. Otherwise,
# updates the file to match it.
func _update_file_group():
	if not file_group:
		# TODO: Read from file
		pass
	else:
		var output = []
		var exit_code = yield(VM.execute("chown", [":%s" % file_group, absolute_path], output), "completed")
		
		if exit_code != 0:
			var message = absolute_path if output.empty() else output[0]
			push_error("Error updating file group: %s" % message)
		
		emit_signal("attributes_changed")


# If `file_mode` is not specified, updates it to match the file. Otherwise,
# updates the file to match it.
func _update_file_mode():
	if not file_mode:
		var output = []
		yield(VM.execute("stat", ["-c", "%f", absolute_path], output), "completed")
		file_mode = output[0]
		emit_signal("attributes_changed")
	else:
		yield(VM.execute("chmod", [file_mode, absolute_path]), "completed")
		emit_signal("attributes_changed")
