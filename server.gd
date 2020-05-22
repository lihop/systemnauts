extends Node


const PORT = 45122
const MAX_PLAYERS = 4


var players = {}


func _ready():
	var server = NetworkedMultiplayerENet.new()
	server.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(server)
	
	get_tree().connect("network_peer_connected", self, "_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	
	var world = load("res://scenes/s_main/S_Main.tscn").instance()
	world.name = "world"
	add_child(world)


func _client_connected(id):
	print("Client ", str(id), " connected to Server")
	
	var new_client = load("res://remote_client.tscn").instance()
	new_client.set_name(str(id))
	new_client.set_network_master(id)
	get_child(0).add_child(new_client)
	
	rpc("player_joined", id)
	
	# Tell the new player about existing players
	for player_id in players.keys():
		rpc_id(id, "player_joined", player_id)
	
	# Add the new player to the players dictionary
	players[id] = null # Don't have anyhing to store yet.


func _client_disconnected(id):
	print("Client ", str(id), " disconnected from Server")
	
	rpc("player_left", id)
	
	var player = get_child(0).get_node_or_null(str(id))
	
	if player:
		player.queue_free()
	
	players.erase(id)


remote func _update_client_position(new_position):
	pass
	# TODO assign new position to server's client representation
	# TODO send new position to all other clients
