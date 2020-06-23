extends RigidBody


export(NodePath) var file


func _ready():
	var shape = $directory/static_collision/shape0
	$directory/static_collision.remove_child(shape)
	$directory/static_collision.queue_free()
	add_child(shape)


func interact(body: PhysicsBody):
	print("Da player interacted with me!")
	body.rpc("request_world_change", name, "res://scenes/web_server/WebServer.tscn")
