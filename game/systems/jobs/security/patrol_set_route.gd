class_name PatrolSetRoute
extends AIBehavior

export (Array, NodePath) var patrol_points := []

var current_patrol_point = patrol_points[0] if not patrol_points.empty() else null
