tool
extends SmartObject

export (bool) var enabled := true
export (bool) var clogged := false


func add_options(context: AIDecisionContext) -> void:
	if enabled:
		for child in get_children():
			if child is AIBehavior:
				child.add_options(context)


func _on_UrinateStanding_actor_arrived(actor: AIAgent, action: SmartObjectAction):
	if clogged:
		actor.animation_player.play("Annoyed")
		yield(actor.animation_player, "animation_finished")
	else:
		actor.animation_player.play("UrinateStanding")
		yield(actor.animation_player, "animation_finished")
		actor.stats.apply_effects(action.stat_effects)
	action.emit_signal("completed", true)
