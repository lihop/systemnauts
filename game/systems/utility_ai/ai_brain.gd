class_name AIBrain, "icons/ai_brain_icon.svg"
extends Node

var current_actions := {}
var known_objects := {}

var action_queue := []

var _decision_context := AIDecisionContext.new()


func _ready():
	add_to_group("brains")
	_decision_context.actor = get_parent()


func _process(delta):
	_tick_action_queue(delta, action_queue)


func _physics_process(delta):
	_tick_action_queue(delta, action_queue, true)


func _tick_action_queue(delta: float, queue := [], physics := false) -> void:
	if queue.empty():
		return

	var action = queue.front()

	match action.status:
		AIAbility.Status.IDLE:
			push_error("This should never happen.")
		AIAbility.Status.RUNNING:
			match action.tick_mode:
				AIAbility.TickMode.PROCESS:
					if not physics:
						action.tick(delta)
				AIAbility.TickMode.PHYSICS_PROCESS:
					if physics:
						action.tick(delta)
		_:
			queue.pop_front()


func think_and_act():
	print("Thinking and acting!")
	#think()
	#act()


func think():
	_decision_context.reset()
	_decision_context.current_actions = current_actions.values()
	_decision_context.known_objects = known_objects.values()

	for child in get_children():
		if child is AIBehavior:
			child.add_options(_decision_context)

	for object in known_objects:
		if object is SmartObject and object.behaviors:
			object.behaviors.add_options(_decision_context)

	var options = _decision_context.options
	options.sort_custom(AIOption.Sorter, "score_descending")

	for option in options:
		if option.score == 0 and current_actions.has(option.action):
			stop_action(option.action)

	var to_remove := []
	for current_action in current_actions:
		if not options.has(current_action):
			to_remove.append(current_action)
	for action_to_remove in to_remove:
		if current_actions.has(action_to_remove):
			stop_action(action_to_remove)

	if not options.empty():
		var current_decision = options[0]
		Logger.debug(
			"Actor %s decided to %s." % [get_parent().name, current_decision.decision_name],
			Logger.CATEGORY_BEHAVIOR
		)
		Logger.debug("Score: %s" % current_decision.score, Logger.CATEGORY_BEHAVIOR)

		var action: AIAction = current_decision.action
		if action:
			if not current_actions.has(action):
				if not action.is_connected("completed", self, "_on_action_completed"):
					action.connect(
						"completed", self, "_on_action_completed", [action], CONNECT_ONESHOT
					)
				var context := AIDecisionContext.new()
				context.params = current_decision.params
				action.execute(context)
				current_actions[action] = action

		var current_action_names := PoolStringArray()
		for act in current_actions.values():
			current_action_names.append(act.to_string())
		print("Current actions: [%s]" % current_action_names.join(", "))


func stop_action(action: AIAction):
	action.disconnect("completed", self, "_on_action_completed")
	action.stop()
	current_actions.erase(action)


func act():
	pass


func discover_object(object: SmartObject):
	if object:
		known_objects[object] = object.mental_representation()


func forget_object(object: SmartObject):
	if object:
		known_objects[object].free()
		known_objects.erase(object)


func _on_action_completed(succeeded: bool, action: AIAction):
	current_actions.erase(action)
	var event = AIEventQueue.ActionEvent.new(action, succeeded)
	_decision_context.events.push(event)


func _exit_tree():
	for key in known_objects:
		known_objects[key].free()
