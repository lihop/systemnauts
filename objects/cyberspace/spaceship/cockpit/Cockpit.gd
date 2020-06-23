extends KinematicBody

export(int) var turn_speed = 1
export(int) var speed = 0


func _ready():
	pass


func _set_speed(new_speed: int):
#	speed = 100
#	$Speedometer.text = String(speed)
#	return
	if speed == new_speed:
		return
	
	speed = new_speed
	$Speedometer.set_deferred("text", String(speed))


func _physics_process(delta):
	# Movement code based on this answer by StrikerSVX in the godotengine forums:
	# https://godotengine.org/qa/63203/basic-aircraft-controls?show=63287#c63287
	
	if Input.is_action_pressed("pitch_up"):
		global_rotate(transform.basis.x, turn_speed * delta)
	if Input.is_action_pressed("pitch_down"):
		global_rotate(transform.basis.x, -turn_speed * delta)
	if Input.is_action_pressed("yaw_right"):
		global_rotate(transform.basis.y, -turn_speed * delta)
	if Input.is_action_pressed("yaw_left"):
		global_rotate(transform.basis.y, turn_speed * delta)
	if Input.is_action_pressed("roll_right"):
		global_rotate(transform.basis.z, -turn_speed * delta)
	if Input.is_action_pressed("roll_left"):
		global_rotate(transform.basis.z, turn_speed * delta)
	
	if Input.is_action_pressed("throttle_up"):
		_set_speed(speed + 10)
	if Input.is_action_pressed("throttle_down"):
		_set_speed(speed - 10)
	
	if Input.is_action_just_pressed("crouch"):
		_set_speed(0)
	
	var collision = move_and_collide(-global_transform.basis.z * speed * delta)
	
	if collision:
		speed = 0


func _process(delta):
	var space_cam_transform = $PilotCam.global_transform
	space_cam_transform.origin.z - 3
	$SpaceScreen/Quad/Viewport/SpaceCam.global_transform = space_cam_transform
