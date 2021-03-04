tool
class_name SpawnPoint
extends Position3D

export (Dictionary) var properties setget set_properties

static func get_spawn_point(spawn_point_name: String):
	var scene_tree := Engine.get_main_loop() as SceneTree

	for spawn_point in scene_tree.get_nodes_in_group("spawn_points"):
		if spawn_point.name == spawn_point_name:
			return spawn_point

	push_error("Spawn point '%s' not found." % spawn_point_name)
	return null


func set_properties(new_properties: Dictionary) -> void:
	if properties != new_properties:
		properties = new_properties
		update_properties()


func update_properties():
	if 'name' in properties:
		name = properties.name


func _ready():
	update_properties()
	add_to_group("spawn_points")
