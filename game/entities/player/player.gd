extends KinematicBody
# Copied from https://kidscancode.org/godot_recipes/g101/3d/101_3d_07/ with minor modifications.

const gravity := -30
const max_speed = 8
const mouse_sensitivity = 0.002  # radians/pixel

var velocity = Vector3()

onready var head := $Head
onready var camera := $Head/Eyes


func _ready():
	camera.current = is_network_master()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if not is_network_master():
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.2, 1.2)


func _physics_process(delta):
	if not is_network_master():
		return

	velocity.y += gravity * delta
	var desired_velocity = _get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)


func _get_input():
	var input_dir = Vector3()
	# desired move in camera direction

	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir