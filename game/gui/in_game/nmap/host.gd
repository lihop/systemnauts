class_name NMapHost
extends Area2D

export (String) var ip_address setget set_ip_address


func set_ip_address(value: String) -> void:
	ip_address = value
	$Label.text = value


func get_shape() -> RectangleShape2D:
	return $CollisionShape2D.shape
