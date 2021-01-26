class_name Stats, "../icons/stats_icon.svg"
extends Node


func score_effects(effects: Dictionary) -> float:
	var score := 0.0

	for child in get_children():
		var stat: Stat = child.stat
		var key := stat.name
		var current_value = stat.value
		var future_value = current_value + effects[key] if effects.has(key) else current_value
		score += (
			stat.response_curve.interpolate_baked(current_value)
			- stat.response_curve.interpolate_baked(future_value)
		)

	return score
