extends AIBehavior

export (Array, NodePath) var patrol_points := []
export (bool) var cyclic := false

var current_patrol_point = null
var next_patrol_point = 0


func _ready():
	current_patrol_point = get_node(patrol_points[0]) if not patrol_points.empty() else null


func add_options(context: AIDecisionContext):
	if not enabled or patrol_points.empty():
		return

	context.params = {
		actor = context.actor,
		target = get_node(patrol_points[next_patrol_point]),
	}
	.add_options(context)


func next():
	current_patrol_point = next_patrol_point
	next_patrol_point = (next_patrol_point + 1) % patrol_points.size()
