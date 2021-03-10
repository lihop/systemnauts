extends NetworkNode


func _ready():
	if not OS.has_feature("Server"):
		multiplayer.connect("connected_to_server", self, "_connected")
		multiplayer.connect("server_disconnected", self, "_disconnected")


func _connected():
	rpc("spawn_player")


func _disconnected():
	get_tree().current_scene.sync_root.clear()


func join_game(server_address: String) -> void:
	var peer := NetworkedMultiplayerENet.new()

	# Could also use IPV6 if we configure server correctly.
	#var server_ip := IP.resolve_hostname(hostname, IP.TYPE_IPV4)
	#Logger.trace("Got server ip of %s" % server_ip, Logger.CATEGORY_NETWORK)
	var result = peer.create_client(server_address, Server.SERVER_PORT)

	if result == OK:
		get_tree().multiplayer.network_peer = peer
		Logger.info("Joined game", Logger.CATEGORY_NETWORK)
		get_tree().change_scene("res://servers/mothership/mothership.tscn")
	else:
		Logger.error("Could not connect to server: %s" % result, Logger.CATEGORY_NETWORK)
