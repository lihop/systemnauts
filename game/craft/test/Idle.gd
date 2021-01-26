extends AIAction


class Params:
	extends AIParams
	var actor: AIAgent

	func _init(context).(context):
		pass


func _execute(params: Params):
	var actor = params.actor
	var animation_player: AnimationPlayer = actor.get_node("AnimationPlayer")

	if not animation_player and animation_player.has_animation("Idle"):
		return fail()

	animation_player.current_animation = "Idle"
	animation_player.play()
	yield(animation_player, "animation_finished")
	return succeed()
