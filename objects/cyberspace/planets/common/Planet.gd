extends Spatial
class_name Planet


const CIRCLE_RADIANS = 360 * PI/180 # Radians in a circle.

export(float) var orbital_speed := 0.075

var _angle = 0


func _process(delta):
	return
	
	# Disable orbits for now until flight mechanics are improved, otherwise
	# landing on planets is way too difficult.
	if orbital_speed != 0:
		_angle = fmod((_angle + orbital_speed * delta), CIRCLE_RADIANS)
		_rotate_around(get_parent().global_transform.origin, Vector3(0, 1, 0), _angle)


func _rotate_around(point, axis, angle):
	var rot = angle + rotation.y
	var start = point
	global_translate(-start)
	transform = transform.rotated(axis, -rot)
	global_translate(start)
