extends Consideration


class Params:
	extends AIParams
	var object: SmartObject
	var action: SmartObjectAction

	func _init(context).(context):
		pass


func _score(params: Params) -> float:
	var required_state = params.action.required_state
	var object = params.object

	for key in required_state:
		if not key in object or not object.get(key) == required_state[key]:
			return float(false)

	return float(true)
