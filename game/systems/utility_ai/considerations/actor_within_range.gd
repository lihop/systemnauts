class_name ActorWithinRange
extends Consideration


class Params:
	extends AIParams
	var actor: AIAgent
	var object: SmartObject
	var action: SmartObjectAction
	var ignore_actor_range := false

	func _init(context).(context):
		pass


func _score(params: Params) -> float:
	if params.ignore_actor_range:
		return 1.0

	var actor_position: Vector3 = params.actor.global_transform.origin
	var object_position: Vector3 = params.object.global_transform.origin

	return float(actor_position.distance_to(object_position) < params.action.usage_range)
