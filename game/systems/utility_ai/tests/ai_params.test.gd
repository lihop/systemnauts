extends "res://addons/gut/test.gd"

var context: AIDecisionContext


class Params:
	extends AIParams
	var required_param: Reference
	var default_param := Reference.new()

	func _init(context).(context):
		pass


func before_each():
	context = autofree(AIDecisionContext.new())


func test_params_has_all_params():
	var ref1 = Reference.new()
	var ref2 = Reference.new()
	context.params = {
		required_param = ref1,
		default_param = ref2,
	}
	var params = Params.new(context)
	assert_true("required_param" in params)
	assert_true("default_param" in params)
	assert_eq(params.required_param, ref1)
	assert_eq(params.default_param, ref2)


func test_params_sets_default_param():
	var ref1 = Reference.new()
	context.params = {
		required_param = ref1,
	}
	var params = Params.new(context)
	assert_true("required_param" in params)
	assert_true("default_param" in params)
	assert_eq(params.required_param, ref1)
	assert_true(params.default_param != null)


func test_records_missing_params():
	context.params = {}
	var params = Params.new(context)
	assert_eq(params.get_missing_params().size(), 1)
	assert_eq(params.get_missing_params()[0], "required_param")
