extends AIBehavior


func add_options(context: AIDecisionContext):
	for object in context.known_objects:
		var max_score := 0.0
		var usage_range := 0.0
		var max_scoring_action: AIAction = null

		for action in object.actions:
			$GoToSmartObject.object = object
			$GoToSmartObject.action = action
			context.params = {
				actor = context.actor,
				object = object,
				action = action,
				ignore_actor_range = true,
			}
			var score = action.score(context)
			if score > max_score:
				max_score = score
				max_scoring_action = action
				usage_range = action.usage_range

		context.bonus = max_score
		context.params = {
			actor = context.actor,
			object = object,
			action = max_scoring_action,
			utility = max_score,
			usage_range = usage_range,
			bonus = max_score,
		}
		.add_options(context)
