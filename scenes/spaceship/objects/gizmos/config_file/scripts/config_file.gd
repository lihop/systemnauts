extends RigidBody
class_name ConfFile

const OutlineMaterial = preload("../materials/outline_material.tres")


var selected := false


func _ready():
	set_mode(MODE_KINEMATIC)
	var shape = $config_file/static_collision/shape0
	$config_file/static_collision.remove_child(shape)
	$config_file/static_collision.queue_free()
	add_child(shape)
	


func select(body):
	selected = true
	$config_file.set_surface_material(0, $config_file.mesh.surface_get_material(0).duplicate())
	$config_file.get_surface_material(0).next_pass = OutlineMaterial


func deselect(body):
	selected = false
	$config_file.set_surface_material(0, null)


func interact(body: PhysicsBody):
	if body.has_method("drop"):
		body.drop()
	
	$AnimationPlayer.current_animation = "slide_out"
	$AnimationPlayer.play()
	yield($AnimationPlayer, "animation_finished")
#	$Tween.interpolate_property(self, "global_transform", self.global_transform,
#			body.global_transform, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()

	if body.has_method("carry"):
		body.carry(self)
