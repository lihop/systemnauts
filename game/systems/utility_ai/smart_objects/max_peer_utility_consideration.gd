extends Consideration
# This considerations searches amongst it's peers to find the highest utility action.


func _score(params: Params) -> float:
	for action in get_parent().get_children():
		if action != self:
			action.score()

	return 0.0
