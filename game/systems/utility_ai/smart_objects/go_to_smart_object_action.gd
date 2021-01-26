extends AIAction

var params: Params
var action: AIAction

onready var object: SmartObject = get_node("../..")


class Params:
	extends AIParams
	var actor: AIAgent
	var object: SmartObject
	var action: AIAction
	var usage_range := 0.5

	func _init(context).(context):
		pass


func _execute(p_params: Params):
	params = p_params
	params.actor.nav_agent.moveTowards(params.object.global_transform.origin)


func _physics_process(delta):
	params.actor.translation = params.actor.nav_agent.position

	if (
		params.actor.global_transform.origin.distance_to(params.object.global_transform.origin)
		<= params.usage_range
	):
		params.actor.nav_agent.stop()
		return succeed()


func _stop():
	params.actor.nav_agent.stop()


func to_string() -> String:
	return "%s(%s to %s)" % [name, object.name, action.to_string()]
