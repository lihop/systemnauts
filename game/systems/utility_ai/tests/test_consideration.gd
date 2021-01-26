extends Consideration


class Params:
	extends AIParams
	var required_param: int
	var required_param2: Reference
	var default_param: int = 5

	func _init(context).(context):
		pass


func _init():
	name = "TestConsideration"


func _score(params: Params) -> float:
	return float(params.default_param + params.required_param)
