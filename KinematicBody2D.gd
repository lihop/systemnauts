extends KinematicBody2D


onready var a = $Area2D

func _ready():
	set_physics_process(true)
	remove_child(a)
	yield(get_tree().create_timer(5), "timeout")
	add_child(a)


func _on_Area2D_body_entered(body):
	if body == self:
		print("me!")
	else:
		print("not me")
