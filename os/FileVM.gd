extends "File.gd"
class_name FileVM

var _inotifier: Inotifier

func _ready():
	_inotifier = $"/root/VM/Inotifier" as Inotifier
	_inotifier.add_event_handler(absolute_path, self, "_update_file_attributes",
			Inotifier.EVENT_ATTRIB)
