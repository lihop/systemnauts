tool
class_name AIAction, "icons/ai_action.svg"
extends Node

const MOMENTUM_BONUS = 1.25

signal completed(success)

export (bool) var enabled := true
export (bool) var interruptable := true
export (float) var weight := 1.0
export (Array, String) var tags := []
export (int, FLAGS, "Legs", "Arms", "Head", "Mouth") var locks = 0

var executing := false

onready var num_considerations = get_child_count()


class Params:
	extends AIParams

	func _init(context).(context):
		pass


func _ready():
	set_process(false)
	set_physics_process(false)


func add_options(context: AIDecisionContext) -> void:
	if enabled:
		_add_options(context)


func _add_options(context: AIDecisionContext) -> void:
	var option = AIOption.new(self)
	option.params = context.params
	option.score = score(context)
	context.options.append(option)
	Logger.trace("Added option '%s', score: %s, params: %s." % [name, option.score, option.params])


func score(context: AIDecisionContext) -> float:
	var bonus = context.bonus if "bonus" in context else 0.0
	if self in context.current_actions:
		bonus += MOMENTUM_BONUS
	var final_score = weight + bonus

	var considerations := []
	for consideration in get_children():
		if consideration.enabled:
			considerations.append(consideration)

	var num_considerations = considerations.size()
	if num_considerations == 0:
		return final_score

	var compensation_factor := 1.0 - (1.0 / float(considerations.size()))

	for consideration in considerations:
		var consideration_score = consideration.score(context)
		print(consideration.name, ' -> ', consideration_score)
		var make_up_value = (1.0 - consideration_score) * compensation_factor
		final_score *= consideration_score + (make_up_value * consideration_score)

	print('fffff final score: ', final_score, ' name: ', name)
	return final_score


func execute(context: AIDecisionContext):
	var params = Params.new(context)
	var missing_params: PoolStringArray = params.get_missing_params()

	if not missing_params.empty():
		push_error(
			(
				"AIAction '%s' missing required params [%s]. Failing."
				% [name, missing_params.join(", ")]
			)
		)
		emit_signal("completed", false)
	else:
		executing = true
		_execute(params)


func _execute(params):
	pass


func stop():
	executing = false
	_stop()


func _stop():
	pass


func succeed():
	stop()
	emit_signal("completed", true)
	for conn in get_signal_connection_list("completed"):
		print(conn)


func fail():
	stop()
	emit_signal("completed", false)


func to_string() -> String:
	return name


func get_actions(params) -> Array:
	push_error("Method not implemented.")
	return []
