extends StaticBody


enum SLOT_TYPES {
	FILE
	DIRECTORY
}

var slot_type
var available := true setget _set_available
var default_collision_layer = collision_layer

func _set_available(available: bool):
	available = available
	
	if available:
		collision_layer = default_collision_layer
	else:
		collision_layer = 0


func select(body):
	if body.has_method("get_carried_items"):
		for item in body.get_carried_items():
			if slot_type == SLOT_TYPES.FILE and item is ConfFile and available:
				get_parent().set_visible(true)
#			if slot_type is SLOT_TYPES.DIRECTORY and item is ConfDir and available:
#				get_parent().set_visible(true)


func deselect(body):
	get_parent().set_visible(false)


func interact(body):
	pass
