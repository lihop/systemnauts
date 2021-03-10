#class_name BaseCharacter
#extends Spatial
#
#var _nav_agent
#
#onready var navigation = get_tree().get_nodes_in_group("navigation")[0]
#
#
#func _ready():
#	var weights: Dictionary = {}
#	weights[0] = 10.0  # Ground
#	weights[1] = 5.0  # Road
#	weights[2] = 10001.0  # Water
#	weights[3] = 10.0  # Door
#	weights[4] = 100.0  # Grass
#	weights[5] = 150.0  # Jump
#	navigation.navigation.setQueryFilter(0, "default", weights)
#
#	_nav_agent = navigation.add_agent(self)
#
#
#func _exit_tree():
#	navigation.remove_agent(self)
