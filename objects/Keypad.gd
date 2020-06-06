extends Spatial


export(String) var directory


func _ready():
	$Label3D.text = "d---------"
	
	if is_network_master():
		_update_permissions()
		Inotifier.add_file_event_handler("/training/second", "first", self,
				"_update_permissions", Inotifier.EVENT_ATTRIB)


remotesync func _update_permissions():
	var output = []
	OS.execute("")


remotesync func _set_permissions_text(text: String) -> void:
	$Label3D.text = "drwxrwxrwx"
