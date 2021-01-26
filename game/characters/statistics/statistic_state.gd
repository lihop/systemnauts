class_name StatisticState
extends Resource

export (String) var id setget set_id
export (float) var threshold


func set_id(value: String) -> void:
	id = value
	resource_name = value
