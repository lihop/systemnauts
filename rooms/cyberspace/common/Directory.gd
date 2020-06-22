extends UnixDirectory
# This directory monitors and manages files within it, including other
# directories.


const TEXT_FILE = preload("res://objects/cyberspace/files/text/Text.tscn")


func _ready():
	$"/root/VM/Inotifier".add_event_handler(absolute_path, self, "_handle_inotify_event")


func _handle_inotify_event(file_name, event):
	match event:
		Inotifier.EVENT_CREATE:
			# TODO: Support other file types
			var new_file = TEXT_FILE.instance()
			new_file.absolute_path = absolute_path
			new_file.file_name = file_name
			new_file.contents = "%s/%s" % [absolute_path, file_name]
			new_file.create = false
			new_file.overwrite = false
			add_child(new_file)
		Inotifier.EVENT_DELETE:
			for node in get_children():
				if node is RegularFile and node.file_name == file_name:
					node.queue_free()
