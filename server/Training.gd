extends Node
class_name SinglePlayerServer
# Base class for single player campaign level servers.


# This is a tutorial level. It is only designed for one player.
const MAX_PLAYERS = 1
const SERVER_PORT = 7154

export(String) var level


func _pre_configure_game():
	# Start in a paused state.
	get_tree().set_pause(true)
	
	# Load world
	var world = load(level).instance()
	get_node("/root").add_child(world)


func _player_connected():
	rpc_id(id, "register_player")


func _player_disconnected():
	pass


func _ready():
	# Setup listeners.
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	# Start networking.
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	
	_pre_configure_game()


func _exit():
	# Terminate networking.
	get_tree().network_peer = null
