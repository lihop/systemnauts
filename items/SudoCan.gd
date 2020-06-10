extends RigidBody


const EMPTY_EMISSION = Color(0.5, 0.5, 0.5)
const EMPTY_EMISSION_ENERGY = 0.5
const FULL_EMISSION = Color(1, 0, 1)
const FULL_EMISSION_ENERGY = 1

signal drunk()

export(bool) var empty := false setget _set_empty


func _set_empty(empty):
	var material = $"sudo-can".mesh.surface_get_material(0).duplicate()
	$"sudo-can".mesh.surface_set_material(0, material)
	
	if empty:
		material.emission = EMPTY_EMISSION
		material.emission_energy = EMPTY_EMISSION_ENERGY
	else:
		material.emission = FULL_EMISSION
		material.emission_energy = FULL_EMISSION_ENERGY


func interact(body):
	if body.is_in_group("player"):
		body.consume(self)
	if not empty:
		_drink()


func _drink():
	$OpeningAudio.play()
	yield($OpeningAudio, "finished")
	self.empty = true
	emit_signal("drunk")
