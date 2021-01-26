extends ReGoapSensor


func _ready():
	for child in get_children():
		if child is Statistic:
			child.connect("state_changed", self, "_on_statistic_state_changed")
			var states = child.get_states()
			for key in states.keys():
				set_state(key, states[key])


func _on_statistic_state_change(key: String, value: bool) -> void:
	set_state(key, value)
