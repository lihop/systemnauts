extends AnimationTree

onready var character := get_parent()


func _process(delta):
	var iwr_blend_amount = range_lerp(character.velocity.length(), 0, character.max_speed, -1, 1)
	set("parameters/iwr_blend/blend_amount", iwr_blend_amount)
