extends Node


#const HOME_SCENE := preload("res://scenes/main/Main.tscn")
#const WEBSERVER_SCENE := preload("res://scenes/web_server/WebServer.tscn")
const DEMO_SCENE := preload("res://scenes/demo/Demo.tscn")

# Change the main scene here.
const MAIN_SCENE := DEMO_SCENE

const SERVER_IP := "192.168.56.110"
const SERVER_PORT := 7154
const MAX_PLAYERS := 4095

var _network_peer := NetworkedMultiplayerENet.new()
var _player: KinematicBody
var _main_world: Node


func _ready():
	print("readying!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	if OS.has_feature("Server"):
		_network_peer.create_server(SERVER_PORT, MAX_PLAYERS)
		print("created server!")
	else:
		_network_peer.create_client(SERVER_IP, SERVER_PORT)
		print("created client!")
	
	get_tree().network_peer = _network_peer
	_network_peer.connect("peer_connected", self, "_peer_connected")
	_network_peer.connect("peer_disconnected", self, "_peer_disconnected")

	# Create and add the world, setting the server as master.
	_main_world = preload("res://scenes/demo/Demo.tscn").instance()
	_main_world.name = "World"
	_main_world.set_network_master(1)
	add_child(_main_world)


func _create_player(peer_id) -> KinematicBody:
	var player: KinematicBody = preload("res://entities/player/Player.tscn").instance()
	player.name = str(peer_id)
	player.set_network_master(peer_id)
	player.connect("world_change_requested", self, "_on_world_change_requested")
	return player


func _peer_connected(peer_id):
	print("PEER_CONNECTED QUITTING!")
	get_tree().quit()
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
		print("i am connnected to server!")
		# Add myself to the world, setting me as master.
		var my_id = get_tree().get_network_unique_id()
		_player = _create_player(my_id)
		_main_world.add_child(_player)


func _peer_disconnected(peer_id):
	print("PEER_DISCONNECTED QUITTING!")
	get_tree().quit()
	print("peer disconnected: ", peer_id)
	if OS.has_feature("Server"):
		print(_main_world.has_node(_player.get_path()))
		_main_world.remove_child(_player)
	else:
		pass
