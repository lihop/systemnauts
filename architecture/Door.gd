tool
extends Spatial


export(NodePath) var directory_a
export(NodePath) var directory_b

const LOCKED_COLOR = Color(1, 0, 0)
const UNLOCKED_COLOR = Color(0, 1, 0)

onready var _directory_a := get_node(directory_a)
onready var _directory_b := get_node(directory_b)
onready var _doorway_side_a: StaticBody = $"door-frame/door-way-side-a/static_collision"
onready var _doorway_side_b: StaticBody = $"door-frame/door-way-side-b/static_collision"

var _collision_exceptions = {}
var _watched_bodies = {}

func _ready():
	# Remove labels which are only used for convience in the editor to easily
	# tell which side of the door is which.
	if not Engine.is_editor_hint():
		$LabelSideA.queue_free()
		$LabelSideB.queue_free()
	
	# Use StaticBody door-way collision shape for Area
#	$Area/CollisionShape.shape = $"door-frame/door-way/shape0".shape
#	$"door-frame".remove_child($"door-frame/door-way")
#	$Area
	
	_directory_a.connect("attributes_changed", self, "_set_collisions",
			[_doorway_side_a, _directory_a])
	_directory_b.connect("attributes_changed", self, "_set_collisions",
			[_doorway_side_b, _directory_b])
	
	_set_collisions(_doorway_side_a, _directory_a)
	_set_collisions(_doorway_side_b, _directory_b)
	
	for user in get_tree().get_nodes_in_group("users"):
		# Ensure collisions will be re-checked if the user's username or groups change.
		user.connect("username_changed", self, "_set_user_collisions", [user])
		user.connect("groups_changed", self, "_set_user_collisionsr", [user])


func _set_collisions(doorway_side: StaticBody, directory: UnixFile):
	# Set collision exceptions based on whether or not user is able to cd into
	# the given directory.
	for user in get_tree().get_nodes_in_group("users"):
		_set_collision_for_user(doorway_side, directory, user)


func _set_user_collisions(user: PhysicsBody):
	_set_collision_for_user(_doorway_side_a, _directory_a, user)
	_set_collision_for_user(_doorway_side_b, _directory_b, user)


# Check whether a user can `cd` into directory. Adds a collision exception if
# they can and removes collision exceptions if they cannot.
func _set_collision_for_user(doorway_side: StaticBody, directory: UnixFile,
		user: PhysicsBody):
	# Note that we use `test` rather than `cd` because `cd` is a shell
	# builtin not an executable. So we can't use it with VM.execute
	# which runs an executable (as a specified user) and then exits.
	var exit_code = yield(VM.execute("test", ["-x", directory.absolute_path],
			[], user.username), "completed")
	
	var material: ShaderMaterial = doorway_side.get_parent().get_surface_material(0)
	
	if exit_code == 0:
		# Make sure we only add the exception once. Otherwise we would need to
		# remove it as many times as we added it.
		if not doorway_side.get_collision_exceptions().has(user):
			doorway_side.add_collision_exception_with(user)
			material.set_shader_param("Color", UNLOCKED_COLOR)
	else:
		doorway_side.remove_collision_exception_with(user)
		material.set_shader_param("Color", LOCKED_COLOR)


func _on_doorway_body_entered(body):
	_watched_bodies[body] = _get_directory(body)


func _on_doorway_body_exited(body):
	_get_directory(body)
	_watched_bodies.erase(body)


# Returns the absolute_path of the directory that `body` is currently in
# based on its position with relation to the doorway.
func _get_directory(body) -> String:
	var doorway = $"door-frame/door-way-side-a/static_collision"
	var A = doorway.global_transform
	
	var AB = A.origin.direction_to(body.global_transform.origin)
	var fA = A.basis.y
	
	if AB.dot(fA) > 0:
		return _directory_a.absolute_path
	else:
		return _directory_b.absolute_path


func _physics_process(delta):
	for body in _watched_bodies:
		var directory = _get_directory(body)
		
		if _watched_bodies[body] != directory:
			print("changing directory to: ", directory)
			_watched_bodies[body] = directory
			body.get_node("Shell").change_directory(directory)
