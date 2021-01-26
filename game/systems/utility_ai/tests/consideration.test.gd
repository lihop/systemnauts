extends "res://addons/gut/test.gd"

const TestConsideration = preload("test_consideration.gd")

var consideration: Consideration
var context: AIDecisionContext


func before_each():
	consideration = partial_double(TestConsideration).new()
	context = autofree(AIDecisionContext.new())


func test_consideration_calls__score_when_called_with_required_params():
	context.params = {
		required_param = 1,
		required_param2 = Reference.new(),
	}
	var _score = consideration.score(context)
	assert_call_count(consideration, "_score", 1)


func test_consideration_vetoes_action_if_missing_required_param():
	context.params = {}
	var score = consideration.score(context)
	assert_eq(score, 0.0)
	assert_call_count(consideration, "_score", 0)


func test_consideration_uses_params():
	context.params = {
		required_param = 1,
		required_param2 = Reference.new(),
		default_param = 2,
	}
	var score = consideration.score(context)
	assert_eq(score, 3.0)


func test_consideration_uses_default_params():
	context.params = {
		required_param = 5,
		required_param2 = Reference.new(),
	}
	var score = consideration.score(context)
	assert_eq(score, 10.0)
