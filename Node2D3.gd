extends Node2D

signal loled()

func _do_thing():
	print("lol")
	emit_signal("loled")
	yield(get_tree().create_timer(5), "timeout")
	print("hahaha")
	
