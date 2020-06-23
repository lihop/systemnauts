extends Node
class_name MultiplayerWorldManager


const HOME_SCENE := preload("res://scenes/main/Main.tscn")
const WEBSERVER_SCENE := preload("res://scenes/web_server/WebServer.tscn")

const SERVER_IP := "192.168.56.110"
const SERVER_PORT := 7154
const MAX_PLAYERS := 4095

var _network_peer := NetworkedMultiplayerENet.new()
var _player: KinematicBody
var _main_world: Node
var _worlds = {}


func add_world(name: String, scene: PackedScene) -> Node:
	# Thanks to shianiawhite for this technique:
	# https://godotengine.org/qa/27962/running-multiple-viewports-and-switching-which-one-active
	
	var container = ResizeableViewportContainer.new()
	container.name = "Container%s" % name
	container.stretch = true
	
	var viewport = Viewport.new()
	viewport.name = "Viewport%s" % name
	viewport.world = World.new()
	
	var world = scene.instance()
	world.name = name
	world.set_network_master(1)
	viewport.add_child(world)
	
	container.add_child(viewport)
	add_child(container)
	
	container.resize_to_fill_root_viewport()
	
	return world


func remove_world(name: String) -> void:
	pass


func _ready():
	if OS.has_feature("Server"):
		_network_peer.create_server(SERVER_PORT, MAX_PLAYERS)
	else:
		_network_peer.create_client(SERVER_IP, SERVER_PORT)
	
	get_tree().network_peer = _network_peer
	_network_peer.connect("peer_connected", self, "_peer_connected")
	_network_peer.connect("peer_disconnected", self, "_peer_disconnected")

	# Create and add the world, setting the server as master.
	_main_world = add_world("Main", WEBSERVER_SCENE)


func _create_player(peer_id) -> KinematicBody:
	var player: KinematicBody = preload("res://entities/player/Player.tscn").instance()
	player.name = str(peer_id)
	player.set_network_master(peer_id)
	player.connect("world_change_requested", self, "_on_world_change_requested")
	return player


func _peer_connected(peer_id):
	# TODO: The code in here can be compressed further.
	
	if OS.has_feature("Server"):
		# Player connected.
		print("player is connnected")
		print(str(peer_id))
		
		# Add the player as a child of the world, setting them as their own master.
		_player = _create_player(peer_id)
		_main_world.add_child(_player)
		
		print_tree_pretty()
	else:
		if peer_id == 1:
			# Add myself to the world, setting me as master.
			var my_id = get_tree().get_network_unique_id()
			_player = _create_player(my_id)
			_main_world.add_child(_player)


func _peer_disconnected(peer_id):
	print("peer disconnected: ", peer_id)
	if OS.has_feature("Server"):
		print(_main_world.has_node(_player.get_path()))
		_main_world.remove_child(_player)
	else:
		pass


func _on_world_change_requested(world_name, world_scene):
	print("player requested a world change to ", world_name, " with scene ", world_scene)
	var new_world = add_world(world_name, load(world_scene))
	#var new_player = _create_player(int(_player.name))
	_main_world.remove_child(_player)
	new_world.add_child(_player)


class ResizeableViewportContainer:
	extends ViewportContainer
	
	
	func _ready():
		get_viewport().connect("size_changed", self, "resize_to_fill_root_viewport")
	
	
	func resize_to_fill_root_viewport():
		var root_viewport = get_viewport()
		
		if root_viewport:
			rect_size = root_viewport.size
			var viewport: Viewport = get_child(0)
			if viewport:
				viewport.size = rect_size
