
extends StaticBody

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.on_ladder = true

func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		body.on_ladder = false
