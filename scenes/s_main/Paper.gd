extends StaticBody


var printed = false


func _ready():
	pass


func interact(relate):
	if printed:
		printed = false
		var paper = relate.find_node("Paper", true)
		paper.pickup()
		$AudioStreamPlayer3D.play()
		get_parent().reset()
