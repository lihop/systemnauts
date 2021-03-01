class_name BaseServer
extends Spatial
# The root node of a Mission scene.

onready var navigation: DetourNavigation = $Navigation
onready var map: QodotMap = $Navigation/Map


func _ready():
	pass
#	for object in get_tree().get_nodes_in_group("smart_objects"):
#		for brain in get_tree().get_nodes_in_group("brains"):
#			brain.discover_object(object)
#
#	Logger.info("Something", Logger.CATEGORY_AUDIO)
#	for agent in get_tree().get_nodes_in_group("mobile_agents"):
#		if agent is AIAgent:
#			# FIXME: Set default filter elsewhere.
#			var weights: Dictionary = {}
#			weights[0] = 10.0  # Ground
#			weights[1] = 5.0  # Road
#			weights[2] = 10001.0  # Water
#			weights[3] = 10.0  # Door
#			weights[4] = 100.0  # Grass
#			weights[5] = 150.0  # Jump
#			navigation.navigation.setQueryFilter(0, "default", weights)
#
#			print('adding agent now!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', agent)
#			agent.nav_agent = navigation.add_agent(agent)
#			agent.connect("tree_exiting", navigation, "remove_agent", [agent], CONNECT_ONESHOT)
