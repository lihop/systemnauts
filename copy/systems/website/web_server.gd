extends Node


signal received_data

var _server: TCP_Server = TCP_Server.new()
var _connections: Dictionary = {}


func _ready():
	var err = _server.listen(80)


func _process(delta):
	if _server.is_connection_available():
		var new_conn: StreamPeerTCP = _server.take_connection()
		_connections[new_conn.get_instance_id()] = new_conn
	
	for conn_id in _connections.keys():
		var conn: StreamPeerTCP = _connections.get(conn_id, StreamPeerTCP.new())
		
		match conn.get_status():
			StreamPeerTCP.STATUS_ERROR:
				push_error("StreamPeerTCP Error. Host: %s, port: %d" %
						[conn.get_connected_host(), conn.get_connected_port()])
				_connections.erase(conn_id)
			StreamPeerTCP.STATUS_NONE:
				_connections.erase(conn_id)
			StreamPeerTCP.STATUS_CONNECTED:
				var available_bytes = conn.get_available_bytes()
				
				if available_bytes:
					var data = conn.get_data(available_bytes)
					print("Got web request")
					emit_signal("received_data", data)
			StreamPeerTCP.STATUS_CONNECTING, _:
				pass
		
