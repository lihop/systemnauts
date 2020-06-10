extends Node
class_name File


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

export(FileTypes) var type := FILE_REGULAR
export(String) var absolute_path
export(String) var file_owner
export(String) var file_group
export(int) var file_mode


func _ready():
	_ensure_file_exists()
	_update_file_owner()
	_update_file_group()
	_update_file_mode()


func _ensure_file_exists():
	var exit_code = yield(VM.execute("stat", [absolute_path]), "completed")
	
	if exit_code != 0:
		# File doesn't exist, create it.
		match type:
			FILE_REGULAR:
				# First ensure that the files directory exists.
				var output = []
				yield(VM.execute("dirname", [absolute_path], output), "completed")
				yield(VM.execute("mkdir", ["-p", output[0]]), "completed")
				
				# Now create the file.
				yield(VM.execute("touch", [absolute_path]), "completed")
			
			FILE_DIRECTORY:
				yield(VM.execute("mkdir", ["-p", absolute_path]), "completed")
			_:
				# TODO: create other file types
				pass


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


# If `file_mode` is not specified, updates it to match the file. Otherwise,
# updates the file to match it.
func _update_file_mode():
	if not file_mode:
		# TODO: Read file mode
		pass
