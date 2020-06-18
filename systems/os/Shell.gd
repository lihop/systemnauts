extends Process
class_name Shell


# Reference: https://linux.die.net/man/1/stty
const SpecialCharacters = {
	# Sends an interrupt signal.
	INTR = "\u0003", # ^C
}

const CHAR_INTR = SpecialCharacters.INTR

const MAGIC_PID_DELIMITER = "__MAGIC_PID_DELIMITER__"

signal typed(text)
signal data_received(data)
signal directory_changed(new_directory)

export(NodePath) var shell_stream

var _shell_stream: ShellStream
var _pid_file


func _ready():
	_shell_stream = get_node(shell_stream)
	
	var pid_regex = RegEx.new()
	pid_regex.compile(".*%s(?<pid>[0-9]+)%s.*" % [MAGIC_PID_DELIMITER, MAGIC_PID_DELIMITER])
	
	yield(_shell_stream, "data_received")
	yield(_shell_stream, "data_received")
	_shell_stream.put_string("echo %s$$%s" % [MAGIC_PID_DELIMITER, MAGIC_PID_DELIMITER])
	yield(_shell_stream, "data_received")
	_shell_stream.put_string("\n")
	var data = yield(_shell_stream, "data_received")
	var matches = pid_regex.search(data.get_string_from_utf8())
	
	if matches:
		pid = int(matches.get_string("pid"))
	else:
		push_error("Could not get pid for shell %s" % get_instance_id())
	
	yield(reset(), "completed")
	
	# Finally, we can expose the internal _shell_stream now that everything has
	# been set up.
	_shell_stream.connect("data_received", self, "_on_data_received")


func type(text: String):
	_shell_stream.put_string(text)
	emit_signal("typed", text)


func reset():
	# Stop whatever process is currently running in the foreground (if any).
	_shell_stream.put_string(CHAR_INTR)
	yield(_shell_stream, "data_received")
	
	# Reset the terminal.
	_shell_stream.put_string("reset")
	yield(_shell_stream, "data_received")
	_shell_stream.put_string("\n")


func change_directory(absolute_path: String) -> void:
	type("cd %s\n" % absolute_path)
	var new_directory = yield(get_cwd_async(), "completed")
	emit_signal("directory_changed", new_directory)


func _on_data_received(data: PoolByteArray):
	emit_signal("data_received", data)
