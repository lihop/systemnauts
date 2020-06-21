extends UnixFile
class_name RegularFile


export(String, FILE) var contents


func _ready():
	type = UnixFile.FILE_REGULAR


func _file_exists() -> bool:
	var result = yield(_OS.execute("sh", ["-c", "\"'[ -f %s ]'\"" % absolute_path]), "completed")
	return result.exit_code == 0


func _contents_match() -> bool:
	var result = yield(_OS.execute("cmp", ["--silent",
			ProjectSettings.globalize_path(contents),absolute_path]),
			"completed")
	return result.exit_code == 0


func _create() -> int:
	var result
	
	if overwrite and yield(._file_exists(), "completed") and \
			not yield(_contents_match(), "completed"):
		print("overwriting!")
		yield(call("_delete"), "completed")
	elif yield(._file_exists(), "completed"):
		return OK
	
	if contents:
		result = yield(_OS.execute("cp", [ProjectSettings.globalize_path(contents),
				absolute_path]), "completed")
	else:
		result = yield(_OS.execute("touch", [absolute_path]), "completed")
	
	match result.exit_code:
		0:
			emit_signal("created")
			return OK
		_:
			return ERR_BUG
