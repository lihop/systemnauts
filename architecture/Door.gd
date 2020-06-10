extends Spatial


export(String) var parent_directory
export(String) var child_directory


func _ready():
	_set_collisions($"door-frame/door-way-parent/static_collision", parent_directory)
	_set_collisions($"door-frame/door-way-child/static_collision", child_directory)


func _set_collisions(collision, directory):
	# Sets collisions of parent and child based on file permissions.
	var output = []
	var exit_code = VM.execute("stat", ["-c", "%a", parent_directory], output)
