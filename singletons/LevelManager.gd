extends Node


const SERVER_PORT := 7154
const MAX_PLAYERS := 1 # Although this is a single player server, if we set
# MAX_PLAYERS to 1 it takes a while for the server to register that we disconnected
# and so we can't join the server again for a while.

var _network_peer: NetworkedMultiplayerENet
var _level: PackedScene


func _ready():
	if OS.has_feature("Server"):
		_network_peer = NetworkedMultiplayerENet.new()
		_network_peer.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = _network_peer
		_network_peer.connect("peer_disconnected", self, "_peer_disconnected")


func start_level(level: String) -> void:
	if OS.has_feature("Server"):
		push_error("tried connecting to a server from another server")
		return
	
	_level = load(level)
	
	# TODO: Don't hardcode level server ip.
	_network_peer = NetworkedMultiplayerENet.new()
	
	_network_peer.connect("peer_connected", self, "_peer_connected")
	
	_network_peer.create_client("192.168.56.109", SERVER_PORT)
	get_tree().network_peer = _network_peer
	
	# Make a VM node puppet of the level server.
	VM.set_network_master(1)


func _peer_connected(id):
	# Temporary workaround. Kill socat servers. The sockets aren't being cleaned
	# up nicely and it is causing lots of problems.
	OS.execute("pkill", ["socat"])
	
	var self_peer_id = get_tree().get_network_unique_id()
	
	var err = get_tree().change_scene_to(_level)
	if err != OK:
		print("Error changing scene: ", err)
	
	get_tree().current_scene.set_network_master(self_peer_id)


func _peer_disconnected(id):
	pass
