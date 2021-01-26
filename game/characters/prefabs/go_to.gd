extends AIAbility

onready var agent: AIAgent = get_parent()

var target
var arrival_range := 0.5


func _start(params: Dictionary):
	if not "target" in params:
		push_error("Missing 'target' param.")
		status = Status.FAILURE

	target = params.target

	if "arrival_range" in params:
		arrival_range = params.arrival_range

	agent.nav_agent.moveTowards(target)


func _tick(_delta: float) -> int:
	if status == Status.FAILURE:
		return status

	var agent_position = agent.global_transform.origin

	if agent_position.distance_to(target) <= arrival_range:
		status = Status.SUCCESS
	else:
		status = Status.RUNNING

	return status

	# TODO: Handle getting stuck.


func stop():
	agent.nav_agent.stop()
