extends Area


func _ready():
	var area_shape = $Model/leroy/area/shape0
	$Model/leroy/area.remove_child(area_shape)
	add_child(area_shape)
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: PhysicsBody) -> void:
	print(body.name, " entered directory ", name)
