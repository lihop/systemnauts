extends Consideration


class Params:
	extends AIParams
	var actor: AIAgent
	var object: SmartObject
	var action: SmartObjectAction

	func _init(context).(context):
		pass


func _score(params: Params) -> float:
	var actor_position = params.actor.global_transform.origin
	var object_position = params.object.global_transform.origin

	return float(actor_position.distance_to(object_position) < params.action.usage_range)
