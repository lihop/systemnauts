extends Shell
# A shell, but spawn on a remote peer using rpc calls.


# If set to true remote shells will only be created when OS.has_feature("Server")
# is true. This is just an extra safety feature to ensure that you don't end up
# creating shells on machines you didn't intend to.
export(bool) var server_only = true

export(NodePath) var shell

# The id of the peer that the shell should be spawned on. Defaults to network
# master.
var server_peer_id := 1


func _ready():
	if server_only and not OS.has_feature("Server"):
		return
	
	if server_peer_id == get_tree().get_network_unique_id():
		get_node(shell).connect("data_received", self, "_send_data_to_client")


func send_data(data: PoolByteArray) -> void:
	rpc_id(server_peer_id, "_send_data_to_server", data)


remote func _send_data_to_server(data: PoolByteArray) -> void:
	if server_only and not OS.has_feature("Server"):
		push_error("_send_data_remote can only be called on server")
		return
	get_node(shell).send_data(data)


func _send_data_to_client(data: PoolByteArray) -> void:
	rpc_unreliable("_client_receive_data", data)


remote func _client_receive_data(data: PoolByteArray) -> void:
	emit_signal("data_received", data)
