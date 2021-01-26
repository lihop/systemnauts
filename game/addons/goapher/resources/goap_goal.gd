tool
extends Resource
class_name GOAPGoal

export (Dictionary) var goal := {} setget set_goal
export (bool) var interrupts := false
export (float) var priority := 50
export (Dictionary) var on_completion := {} setget set_on_completion


func set_goal(value: Dictionary) -> void:
	goal = value
	for key in goal.keys():
		if typeof(key) != TYPE_STRING or typeof(goal[key]) != TYPE_BOOL:
			push_error("goal must be a Dictionary of String/bool pairs")
			goal.erase(key)


func set_on_completion(value: Dictionary) -> void:
	on_completion = value
	for key in on_completion.keys():
		if typeof(key) != TYPE_STRING or typeof(on_completion[key]) != TYPE_BOOL:
			push_error("on_completion must be a Dictionary of String/bool pairs")
			on_completion.erase(key)


func _init(p_goal := {}, p_interrupts := false, p_priority := 1) -> void:
	goal = p_goal
	interrupts = p_interrupts
	priority = p_priority
