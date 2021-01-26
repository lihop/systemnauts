class_name GenericSmartObjectAction
extends SmartObjectAction

signal actor_arrived(actor, action)

export (String) var animation_name
export (Animation) var animation

var params: Params


func add_options(context: AIDecisionContext):
	context.params = {
		actor = context.actor,
		object = get_parent().get_parent(),
		action = self,
	}
	.add_options(context)


func _execute(params):
	pass


func _on_StateMachinePlayer_updated(state, delta):
	match state:
		"GoTo":
			pass
			#params.actor.go_to.tick(delta)
		"UseSmartObject":
			if params.actor.animation_player.is_playing():
				pass
			else:
				object_actual.apply_state_effect(params.action.state_effects)
				params.actor.stats.apply_stat_effects(params.action.stat_effects)


func _on_StateMachinePlayer_transited(from, to):
	match to:
		"GoTo":
			pass
			#params.actor.go_to(params.target)
		"UseSmartObject":
			if animation_name and params.actor.animation_player.has_animation(animation_name):
				params.actor.animation_player.play(animation_name)
