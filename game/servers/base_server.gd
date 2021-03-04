class_name BaseServer
extends Spatial
# The root node of a Mission scene.

onready var navigation: DetourNavigation = $Navigation
onready var map: QodotMap = $Navigation/Map


func _ready():
	var SSHD = get_node("/root/SSHD")
	SSHD.connect("SSHDStarted", self, "_on_SSHDStarted")
	SSHD.connect("SSHDStopped", self, "_on_SSHDStopped")
	SSHD.connect("HostConnected", self, "_on_HostConnected")
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


func _on_SSHDStarted():
	print("SSHDStarted")


func _on_SSHDStopped():
	print("SSHDStopped")


func _on_HostConnected(ip_address):
	print("Host %s connected" % ip_address)
	if multiplayer.is_network_server():
		_spawn_visitor()


master func _spawn_visitor():
	var visitor = preload("res://entities/characters/npcs/visitor/visitor.tscn").instance()
	var spawn_point: SpawnPoint = SpawnPoint.get_spawn_point("PassportControl_SpawnPoint_0")

	SyncRoot.add_child(visitor, true)
	visitor.global_transform.origin = spawn_point.global_transform.origin
