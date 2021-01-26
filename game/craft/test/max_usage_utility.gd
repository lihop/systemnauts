extends Consideration


class Params:
	extends AIParams
	var object: SmartObject

	func _init(context).(context):
		pass


func score(context: AIDecisionContext) -> float:
	var params: Params = Params.new(context)
	var max_score := 0.0

	for action in params.object.actions:
		context.params["action"] = action
		context.params["ignore_actor_range"] = true
		max_score = max(action.score(context), max_score)
		print('mmm max score ', max_score, ' for action ', action.name)

	return max_score
