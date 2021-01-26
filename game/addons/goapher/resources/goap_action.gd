tool
extends Resource
class_name GOAPAction

export (Dictionary) var effect := {} setget set_effect
export (Dictionary) var required := {} setget set_required
export (float) var cost := 1


func set_effect(value: Dictionary) -> void:
	effect = value
	for key in effect.keys():
		if typeof(key) != TYPE_STRING or typeof(effect[key]) != TYPE_BOOL:
			push_error("effect must be a Dictionary of String/bool pairs")
			effect.erase(key)


func set_required(value: Dictionary) -> void:
	required = value
	for key in required.keys():
		if typeof(key) != TYPE_STRING or typeof(required[key]) != TYPE_BOOL:
			push_error("required must be a Dictionary of String/bool pairs")
			required.erase(key)


func _init(p_effect := {}, p_required := {}, p_cost := 1) -> void:
	effect = p_effect
	required = p_required
	cost = p_cost
