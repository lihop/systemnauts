extends "res://addons/sync_sys/sync_transform_3d.gd"


func get_class():
	return "SyncNode"


func _process(delta):
	if not enabled:
		return

	if is_network_master():
		data.velocity = node.velocity
	else:
		if !data.has("velocity"):
			return
		if interpolate:
			node.velocity = lerp(node.velocity, data.velocity, lerp_speed * delta)
		else:
			node.velocity = data.velocity
