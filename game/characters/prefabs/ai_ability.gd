class_name AIAbility
extends Node

enum Lock {
	LEGS,
	ARMS,
	HEAD,
	MOUTH,
}

enum Status {
	IDLE,
	RUNNING,
	SUCCESS,
	FAILURE,
	ABORTED,
}

enum TickMode {
	PROCESS,
	PHYSICS_PROCESS,
}

export (Lock, FLAGS) var locks
export (TickMode) var tick_mode: int = TickMode.PROCESS

var status: int = Status.IDLE


func start(params: Dictionary) -> int:
	assert(status == Status.IDLE, "Ability should not be in use.")
	status = Status.RUNNING
	return _start(params)


func _start(params: Dictionary) -> int:
	push_error("Method not implemented.")
	return Status.FAILURE


func stop():
	status = Status.IDLE
	_stop()


func _stop():
	pass


func tick(delta: float) -> int:
	if status == Status.FAILURE:
		return status
	else:
		return _tick(delta)


func _tick(delta: float) -> int:
	return Status.RUNNING
