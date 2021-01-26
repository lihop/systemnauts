extends Consideration


class Params:
	extends AIParams
	var utility: float

	func _init(context).(context):
		pass


func _score(params: Params) -> float:
	return float(true) if params.utility > 0 else float(false)
