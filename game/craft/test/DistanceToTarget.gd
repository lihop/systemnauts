class_name DistanceToTarget
extends Consideration

export (String) var from_param := "actor"
export (String) var to_param := "target"
export (float) var range_min := 0
export (float) var range_max := 500


func score(context: AIDecisionContext) -> float:
	var params = context.params

	if "usage_range" in params:
		range_min = params.usage_range

	if not params.has_all([from_param, to_param]):
		push_warning("Consideration '%s' missing params." % name)
		return 0.0

	var from = params[from_param]
	var to = params[to_param]

	var distance: float

	if from is Spatial and to is Spatial:
		distance = from.global_transform.origin.distance_to(to.global_transform.origin)
	elif from is Node2D and to is Node2D:
		distance = from.global_position.distance_to(to.global_position)
	else:
		push_warning("Consideration '%s' param has wrong type." % name)
		return 0.0

	var result = 1 - clamp((distance - range_min) / (range_max - range_min), 0, 1)
	return result
