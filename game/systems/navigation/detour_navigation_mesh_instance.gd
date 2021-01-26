tool
class_name DetourNavigationMeshInstance, "icon_navigation_mesh_instance.svg"
extends Spatial

signal debug_toggled(value)

export (Resource) var navmesh setget set_navmesh
export (bool) var debug := false setget set_debug

var debug_mesh_instance: MeshInstance


func set_navmesh(value) -> void:
	navmesh = value
	update_configuration_warning()


func set_debug(value: bool) -> void:
	debug = value
	emit_signal("debug_toggled", value)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			for connection in get_signal_connection_list("debug_toggled"):
				if connection.target != get_parent():
					disconnect("debug_toggled", connection.target, connection.method)
					if get_node(debug_mesh_instance.name):
						debug_mesh_instance.queue_free()
			update_configuration_warning()


func _get_configuration_warning() -> String:
	var warnings := PoolStringArray([])

	if not navmesh is DetourNavigationMesh:
		warnings.append(
			"A DetourNavigationMesh resource must be set or created for this node to work."
		)
	if get_parent().get_class() != "DetourNavigation":
		warnings.append(
			"DetourNavigationMeshInstance only serves to provide a navigation mesh to a DetourNavigation node. Please only use it as a child of DetourNavigation."
		)

	return "%s" % warnings.join("\n\n")
