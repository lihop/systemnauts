extends Spatial


export(NodePath) var directory_a
export(NodePath) var directory_b

onready var _directory_a := get_node(directory_a)
onready var _directory_b := get_node(directory_b)
onready var _doorway_side_a := $"door-frame/door-way-side-a/static_collision"
onready var _doorway_side_b := $"door-frame/door-way-side-b/static_collision"


func _ready():
	# Remove labels which are only used for convience in the editor to easily
	# tell which side of the door is which.
	if not Engine.is_editor_hint():
		$LabelSideA.queue_free()
		$LabelSideB.queue_free()
	
	_directory_a.connect("attributes_changed", self, "_set_collisions",
			[_doorway_side_a, _directory_a])
	_directory_b.connect("attributes_changed", self, "_set_collisions",
			[_doorway_side_b, _directory_b])
	
	_set_collisions(_doorway_side_a, _directory_a)
	_set_collisions(_doorway_side_b, _directory_b)


func _set_collisions(doorway_side: StaticBody, directory: UnixFile):
	# Set the primary collision state based on the world execute permissions.
	if directory.check_permission(UnixFile.CLASS_WORLD, UnixFile.PERM_EXECUTE):
		doorway_side.set_collision_layer_bit(0, 0)
	else:
		doorway_side.set_collision_layer_bit(0, 1)
	
	# Add exceptions based on group.
	if directory.check_permission(UnixFile.CLASS_GROUP, UnixFile.PERM_EXECUTE):
		for node in get_tree().get_nodes_in_group(directory.file_group): # TODO: Use group_gid
			doorway_side.add_collision_exception_with(node)
	
	# Add exception based on owner.
	if directory.check_permission(UnixFile.CLASS_OWNER, UnixFile.PERM_EXECUTE):
		# TODO: Use group "user" rather than "player".
		for node in get_tree().get_nodes_in_group("player"):
			# TODO: Use uid rather than username as multiple usernames
			# can have the same uid.
			if node.username == directory.file_owner: # TODO: user owner_uid
				doorway_side.add_collision_exception_with(node)
