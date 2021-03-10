extends "res://addons/sync_sys/sync_root.gd"


func clear_sync_nodes(node = self):
	for child in node.get_children():
		if child.has_method("get_class") and child.get_class() == "SyncNode":
			node.queue_free()
			break
		else:
			clear_sync_nodes(child)
