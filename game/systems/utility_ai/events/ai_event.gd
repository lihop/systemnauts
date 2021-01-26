class_name AIEventQueue
extends Reference

var _queue := []


func push(event: AIEvent):
	_queue.push_front(event)


class AIEvent:
	extends Reference
	var time := OS.get_ticks_msec()


class ActionEvent:
	extends AIEvent

	var action
	var succeeded := true

	func _init(p_action, p_succeeded := true):
		action = p_action
		succeeded = p_succeeded
