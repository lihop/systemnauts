class_name Statistic
extends Node

signal state_changed(id, state)

export var default := 0.5
export (Array) var above setget set_above
export (Array) var below setget set_below

var current: float setget set_current


func _ready() -> void:
	current = default


func adjust(amount: float) -> void:
	self.current += amount


func get_states() -> Dictionary:
	var states := {}
	for state in above:
		states[state.id] = current > state.threshold
	for state in below:
		states[state.id] = current < state.threshold
	return states


func set_current(new: float) -> void:
	var previous = current
	current = new

	for state in above:
		if previous <= state.threshold and new > state.threshold:
			emit_signal("state_changed", state.id, true)
		elif previous > state.threshold and new <= state.threshold:
			emit_signal("state_changed", state.id, false)

	for state in below:
		if previous >= state.threshold and new < state.threshold:
			emit_signal("state_changed", state.id, true)
		elif previous < state.threshold and new >= state.threshold:
			emit_signal("state_changed", state.id, false)


func set_above(value: Array) -> void:
	above.resize(above.size())
	above = value
	for i in above.size():
		if not above[i]:
			var statistic_state := StatisticState.new()
			statistic_state.threshold = 1.0
			above[i] = statistic_state


func set_below(value: Array) -> void:
	below.resize(below.size())
	below = value
	for i in below.size():
		if not below[i]:
			var statistic_state := StatisticState.new()
			statistic_state.threshold = 0.0
			below[i] = statistic_state
