class_name SmartObjectBehaviors
extends AIBehavior


func add_options(context: AIDecisionContext):
	context.params = {
		actor = context.actor,
		object = get_parent(),
	}
	return .add_options(context)
