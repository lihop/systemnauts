extends Resource
class_name GOAPState

export (String) var state
export (bool) var value


func _init(p_state := "", p_value := false) -> void:
	state = p_state
	value = p_value
