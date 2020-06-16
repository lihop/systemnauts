
extends RigidBody

var picked_up

var holder

var _saved_material

func pick_up(player):
	holder = player

	if picked_up:
		leave()
	else:
		carry()

func _process(delta):
	if picked_up:
		set_global_transform(holder.get_node("Yaw/Camera/pickup_pos").get_global_transform())

func carry():
	#$CollisionShape.set_disabled(true)
	holder.carried_object = self
	self.set_mode(1)
	picked_up = true
	_saved_material = $MeshInstance.get_surface_material(0).duplicate(true)
	var shader: VisualShader = $MeshInstance.get_surface_material(0).get_shader()
	shader.get_node(VisualShader.TYPE_FRAGMENT, 3).set("constant", 0.5)
	
	

func leave():
	#$CollisionShape.set_disabled(false)
	holder.carried_object = null
	self.set_mode(0)
	picked_up = false
	$MeshInstance.set_surface_material(0, _saved_material)



func throw(power):
	leave()
	apply_impulse(Vector3(), holder.look_vector * Vector3(power, power, power))
