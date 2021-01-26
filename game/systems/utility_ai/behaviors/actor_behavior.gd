class_name AIAgentBehavior
extends AIBehavior


func add_options(context: AIDecisionContext):
	context.params = {actor = context.actor}
	return .add_options(context)
