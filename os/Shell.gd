extends Node


signal connected()
signal data_received(data)
signal test()

var _socket_path: String
var _socat_pid: int
var _stream_peer: StreamPeerUnix


func _ready():
	_socket_path = ProjectSettings.globalize_path("user://%s.sock" % get_instance_id())
	
	# Start a socat server that will open a shell when we connect to it.
	_socat_pid = OS.execute("socat",
			["unix-l:%s,keepalive,reuseaddr,fork" % _socket_path,
			"exec:bash,su=godette,pty,setsid,stderr,login,ctty"], false)
	
	# Initialize and connect the StreamPeer
	_stream_peer = StreamPeerUnix.new()
	
	var err = _stream_peer.open(_socket_path)
	if err != OK:
		push_error("Error opening socket. Path: %s" % _socket_path)
	else:
		emit_signal("connected")


func _process(delta):
	if _stream_peer.get_status() == StreamPeerUnix.STATUS_CONNECTED:
		var available_bytes = _stream_peer.get_available_bytes()
		if available_bytes > 0:
			var result = _stream_peer.get_data(available_bytes)
			if result[0] != OK:
				push_error("Error getting data from StreamPeer")
			else:
				emit_signal("data_received", result[1])


func send_data(data: PoolByteArray) -> void:
	if _stream_peer.get_status() == StreamPeerUnix.STATUS_CONNECTED:
		_stream_peer.put_data(data)


func _exit_tree():
	OS.execute("kill", [_socat_pid])
