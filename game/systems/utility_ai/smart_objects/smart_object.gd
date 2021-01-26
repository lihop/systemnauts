class_name SmartObject
extends Spatial

# Used to set the global_transform.origin of a mental representation of a
# SmartObject when the agent doesn't know where it is.
const GOD_KNOWS_WHERE := Vector3(INF, INF, INF)

var behaviors
var actions: Array setget , get_actions

var _mental_representation: bool


func _ready():
	if _mental_representation:
		set_process(false)
		set_physics_process(false)
	else:
		add_to_group("smart_objects")
		for child in get_children():
			if child is AIBehavior:
				behaviors = child


func get_actions() -> Array:
	var actions := []
	for child in get_children():
		if child is AIBehavior:
			for grandchild in child.get_children():
				if grandchild is AIAction:
					actions.append(grandchild)
	return actions


func mental_representation():
	var repr = duplicate(DUPLICATE_SCRIPTS | DUPLICATE_USE_INSTANCING)
	repr._mental_representation = true
	repr.visible = false
	repr.set_as_toplevel(true)
	for child in repr.get_children():
		if not child is AIBehavior:
			child.free()
	get_parent().add_child(repr)
	return repr
