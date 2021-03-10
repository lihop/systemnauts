tool
extends DetourNavigation


func _ready():
	var weights: Dictionary = {}
	weights[0] = 10.0  # Ground
	weights[1] = 5.0  # Road
	weights[2] = 10001.0  # Water
	weights[3] = 10.0  # Door
	weights[4] = 100.0  # Grass
	weights[5] = 150.0  # Jump
	navigation.setQueryFilter(0, "default", weights)

	for child in get_children():
		if child.has_method("init_navigation"):
			child.init_navigation(self)


func add_child(child, legible_unique_name := false):
	.add_child(child, legible_unique_name)
	if child.has_method("init_navigation"):
		child.init_navigation(self)
