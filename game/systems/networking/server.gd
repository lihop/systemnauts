extends NetworkNode

const SERVER_ID := 1
const SERVER_PORT := 1970
const MAX_PLAYERS := 15


func _ready():
	if OS.has_feature("Server"):
		get_tree().connect("network_peer_connected", self, "_peer_connected")
		get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")


func _peer_connected(id: int) -> void:
	SyncRoot.sync_client(id)


func _peer_disconnected(id: int) -> void:
	var player = SyncRoot.get_node_or_null(str(id))
	if player:
		SyncRoot.remove_child(player)


func start():
	var peer := NetworkedMultiplayerENet.new()

	# Uses ipv6 on digital ocean if we don't call this.
	peer.set_bind_ip("0.0.0.0")

	var result = peer.create_server(SERVER_PORT, MAX_PLAYERS)

	if result == OK:
		get_tree().network_peer = peer
		Logger.info("Server started. Listening on port %d" % SERVER_PORT, Logger.CATEGORY_NETWORK)
	else:
		Logger.error("Error starting server: %d" % result, Logger.CATEGORY_NETWORK)
