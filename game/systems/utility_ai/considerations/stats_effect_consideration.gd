class_name StatEffects
extends Consideration


class Params:
	extends AIParams
	var actor: AIAgent
	var action: SmartObjectAction

	func _init(context).(context):
		pass


func _score(params: Params) -> float:
	var stats := params.actor.stats
	var stat_effects := params.action.stat_effects

	return stats.score_effects(stat_effects)
