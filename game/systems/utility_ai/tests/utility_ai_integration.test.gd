extends "res://addons/gut/test.gd"

var brain: AIBrain
var behavior: AIBehavior
var smart_object: SmartObject


func before_each():
	brain = add_child_autofree(AIBrain.new())
	behavior = partial_double(AIBehavior).new()
	smart_object = add_child_autofree(preload("smart_object_test.tscn").instance())


func test_discover_and_forget_object():
	assert_eq(brain.known_objects.size(), 0)
	brain.discover_object(smart_object)
	assert_eq(brain.known_objects.size(), 1)
	brain.forget_object(smart_object)
	assert_eq(brain.known_objects.size(), 0)


class TestThink:
	extends "res://addons/gut/test.gd"

	var brain: AIBrain
	var behavior

	func before_each():
		brain = add_child_autofree(AIBrain.new())
		behavior = partial_double(AIBehavior).new()

	func test_calls_child_behaviors_with_ai_context():
		brain.add_child(behavior)
		brain.think()
		assert_call_count(behavior, "add_options", 1)

	func test_calls_child_behaviors_with_ai_decision_context():
		brain.add_child(behavior)
		brain.think()
		var params = get_call_parameters(behavior, "add_options")
		assert_true(params[0] is AIDecisionContext)

	func test_resets_options_between_thinks():
		brain.add_child(behavior)
		brain.think()
		var context = get_call_parameters(behavior, "add_options")[0]
		assert_true(context.options.empty())
		context.options.append({})
		assert_false(context.options.empty())
		brain.think()
		context = get_call_parameters(behavior, "add_options")[0]
		assert_true(context.options.empty())

	func test_decision_context_has_known_objects():
		var smart_object = add_child_autofree(preload("smart_object_test.tscn").instance())
		brain.discover_object(smart_object)
		brain.add_child(behavior)
		brain.think()
		var context = get_call_parameters(behavior, "add_options")[0]
		assert_eq(context.known_objects.size(), 1)
