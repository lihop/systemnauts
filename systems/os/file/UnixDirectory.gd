extends UnixFile
class_name UnixDirectory


func _ready():
	type = UnixFile.FILE_DIRECTORY


func _file_exists() -> bool:
	var result = yield(_OS.execute("sh", ["-c", "\"'[ -d %s ]'\"" % absolute_path]), "completed")
	return result.exit_code == 0


func _create() -> int:
	if overwrite and yield(._file_exists(), "completed"):
		_delete()
	
	var result = yield(_OS.execute("mkdir", ["-p", absolute_path]), "completed")
	
	if result.exit_code != 0:
		if overwrite:
			push_error(PoolStringArray(result.output).join("\n"))
			return ERR_BUG
		else:
			return OK
	else:
		emit_signal("created")
		return OK
