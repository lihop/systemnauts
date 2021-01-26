tool
class_name SmartObjectAction
extends AIAction

export (Dictionary) var required_state := {}
export (Dictionary) var stat_effects := {}
export (float) var usage_range := 0.5

onready var object_actual = get_parent().get_parent()


class Params:
	extends AIParams
	var actor: AIAgent
	var object: SmartObject
	var action: SmartObjectAction

	func _init(context).(context):
		pass


func score(context: AIDecisionContext) -> float:
	context.params["action"] = self
	return .score(context)


func _execute(params: Params):
	pass


func get_actions(params: Params) -> Array:
	var actor = params.actor
	var object = params.object
	var actor_position = actor.global_transform.origin
	var object_position = object.global_transform.origin

	return []
