class_name Consideration, "../icons/ai_consideration.svg"
extends Node

export (bool) var enabled := true


class Params:
	extends AIParams

	func _init(context).(context):
		pass


func score(context: AIDecisionContext) -> float:
	var params = Params.new(context)
	var missing_params: PoolStringArray = params.get_missing_params()

	if not missing_params.empty():
		push_error(
			"Consideration '%s' missing param(s) [%s]. Vetoing." % [name, missing_params.join(", ")]
		)
		return 0.0
	else:
		return _score(params)


func _score(_params):
	push_error("Method '_score' not implemented. Vetoing.")
	return 0.0
