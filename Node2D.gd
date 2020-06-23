extends Node2D

onready var a = $Area2D

func _ready():
	set_physics_process(true)
	remove_child(a)
