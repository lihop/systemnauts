extends Label
# Control for displaying the player's current working directory.


export(NodePath) var shell

var _shell: Shell


func _ready():
	_shell = get_node_or_null(shell)
	
	if _shell:
		print("Connectiing shell")
		_shell.connect("pid_updated", self, "_set_label")
		_shell.connect("directory_changed", self, "_on_directory_changed")
		print(_shell)
		print(_shell.get_signal_connection_list("directory_changed"))
	else:
		push_warning("shell %s is null. Label won't work" % shell)


func _on_directory_changed(new_directory):
	print("it changed!: ", new_directory)
	text = new_directory


func _set_label(pid):
	text = yield(_shell.get_cwd_async(), "completed")
