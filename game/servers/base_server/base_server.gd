class_name BaseServer
extends Spatial
# The root node of a Mission scene.

onready var navigation: DetourNavigation = $SyncRoot/Navigation
onready var map: QodotMap = $SyncRoot/Navigation/Map
onready var sync_root = $SyncRoot


func _ready():
	if not is_network_master():
		$SyncRoot.clear_sync_nodes()

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
	return
	var visitor = preload("res://entities/characters/npcs/visitor/visitor.tscn").instance()
	var spawn_point: SpawnPoint = SpawnPoint.get_spawn_point("PassportControl_SpawnPoint_0")

	get_tree().current_scene.sync_root.add_child(visitor, true)
	visitor.global_transform.origin = spawn_point.global_transform.origin


# Copied from https://docs.godotengine.org/en/3.2/tutorials/io/saving_games.html#saving-and-reading-data
func save():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(to_json(node_data))
	save_game.close()


func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return  # No file to load.

	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())

		var new_object = load(node_data["filename"]).instance()
		new_object.name = node_data["name"]

		var path = "%s/%s" % [node_data["parent"], node_data["name"]]

		# Delete node if it already exists as we want to uses loaded (not initial) state.
		var existing = get_node_or_null(path)
		if existing:
			existing.free()

		get_node(node_data["parent"]).add_child(new_object)
		new_object.place_at(str2var(node_data["global_transform"]))
		for k in node_data.keys():
			if k != "filename" or k != "parent" or k != "global_transform":
				new_object.set(k, node_data[k])

	save_game.close()
