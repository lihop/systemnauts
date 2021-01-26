extends AIAction


func _calculate(context: AIDecisionContext):
	context.params.actor = get_parent().decision_maker.actor
	context.params.target = get_parent().get_node(context.patrol_points[context.next_patrol_point])
	return _calculate(context)


func execute(params = {}):
	var actor = params.actor
	var animation_player = actor.get_node("AnimationPlayer")
	animation_player.current_animation = "LookAround"
	animation_player.play()
	get_parent().next()
