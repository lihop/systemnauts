extends Node
class_name SSHStream


signal data_received(data)

export(String) var command
export(NodePath) var ssh_connection

var _ssh_connection: SSHConnection
var _socat_pid: int
var _stream_peer: StreamPeerUnix


func _ready():
	_ssh_connection = get_node(ssh_connection)
	
	var ssh_path = _ssh_connection.ssh_path
	var control_path = _ssh_connection.control_path
	
	var socket_path = "%s-%s" % [control_path, get_instance_id()]
	var address_1 = "unix-l:\"%s\",keepalive,reuseaddr,fork,unlink-early" % socket_path
	var address_2 = "exec:\"%s -S %s - '%s'\",pty,setsid,stderr,login,ctty" % [ssh_path, control_path, command]
	
	# TODO: Use socat_path variable
	_socat_pid = OS.execute("socat", [address_1, address_2], false)
	
	_stream_peer = StreamPeerUnix.new()
	
	# Socket isn't created immediately so delay.
	# TODO: Something better than this.
	yield(get_tree().create_timer(0.5), "timeout")
	
	var err = _stream_peer.open(socket_path)
	
	if err != OK:
		push_error("(%s) error opening socket %s" % [err, socket_path])


func _process(delta):
	# Poll _stream_peer for data.
	if _stream_peer.get_status() == StreamPeerUnix.STATUS_CONNECTED:
		var available_bytes = _stream_peer.get_available_bytes()
		if available_bytes > 0:
			var result = _stream_peer.get_data(available_bytes)
			if result[0] != OK:
				push_error("Error getting data from StreamPeer")
			else:
				emit_signal("data_received", result[1])


func send_data(data: PoolByteArray):
	_stream_peer.put_data(data)


func _exit_tree():
	OS.execute("kill", [_socat_pid])
