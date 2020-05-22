extends Node


func _ready():
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client("nix", 45122)
	get_tree().network_peer = peer
	
	var world = load("res://scenes/s_main/S_Main.tscn").instance()
	world.set_name("world")
	
	var id = get_tree().get_network_unique_id()
	var player = preload("res://addons/RadMatt.3DFPP/Player.tscn").instance()
	player.set_name(str(id))
	player.set_network_master(id)
	player.get_node("Yaw/Camera").current = true
	world.add_child(player)
	add_child(world)


remote func player_joined(id):
	if id == get_tree().get_network_unique_id():
		print("I joined Server")
		return
	
	print("Player ", str(id), " joined Server")
	
	var player = preload("res://addons/RadMatt.3DFPP/Player.tscn").instance()
	player.set_name(str(id))
	player.set_network_master(id)
	player.set_process_unhandled_input(false)
	get_child(0).add_child(player)


remote func player_left(id):
	print("Player ", str(id), " left Server")
	
	var player = get_child(0).get_node_or_null(str(id))
	
	if player:
		player.queue_free()
