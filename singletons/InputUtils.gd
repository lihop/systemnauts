extends Node


# Time in seconds before a press is considered a long press.
const LONG_PRESS_DELAY = 0.5

var _action_timers = {}


func is_action_just_long_pressed(action: String) -> bool:
	return Input.is_action_pressed(action) and \
		_action_timers.has(action) and \
		_action_timers[action].time > LONG_PRESS_DELAY and \
		_action_timers[action].just_long


func is_action_long_pressed(action: String) -> bool:
	return Input.is_action_pressed(action) and \
			_action_timers.has(action) and \
			_action_timers[action].time > LONG_PRESS_DELAY


func _input(event):
	for action in InputMap.get_actions():
		if Input.is_action_just_pressed(action):
			_action_timers[action] = {}
			_action_timers[action].just_long = false
			_action_timers[action].time = 0
		if Input.is_action_just_released(action):
			_action_timers.erase(action)


func _process(delta):
	for action in _action_timers.keys():
		var current_time = _action_timers[action].time
		var new_time = current_time + delta
		
		if current_time < LONG_PRESS_DELAY and new_time > LONG_PRESS_DELAY:
			_action_timers[action].just_long = true
		
		_action_timers[action].time = new_time
