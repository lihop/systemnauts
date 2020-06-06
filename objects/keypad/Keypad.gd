extends Spatial

const DEFAULT_PERMISSIONS = "d?????????"

export(String) var directory

var _permissions := DEFAULT_PERMISSIONS


func _ready():
	$Label3D.text = DEFAULT_PERMISSIONS
	
	if is_network_master():
		_update_permissions()
		Inotifier.add_file_event_handler("/training/second", "first", self,
				"_update_permissions", Inotifier.EVENT_ATTRIB)


func _update_permissions() -> void:
#	var output 
#	var exit_code = yield(RemoteOS.execute("ls", [
#			"\"-ld %s | awk '{print $1}'\"" % directory]), "completed")
#	if exit_code == 0:
#		_permissions = output[0]
#	else:
#		_permissions = DEFAULT_PERMISSIONS
	
	rpc("_set_permissions_text")


remotesync func _set_permissions_text() -> void:
	$Label3D.text = _permissions
