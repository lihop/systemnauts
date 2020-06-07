extends Shell
class_name ShellSocatUnix


# How many times _stream_peer will try to connect to socket_path before
# giving up.
const MAX_RETRIES = 10000

# Path where the Unix domain socat for this shell will be created.
# Can be a localised path (e.g. "user://example.sock").
export(String) var socket_path = ProjectSettings.globalize_path("user://shell.sock") \
		 setget _set_socket_path,_get_socket_path

# Path to the socat executable. Can be a localised path (e.g. "res://bin/socat").
export(String) var socat_path := "socat" setget _set_socat_path,_get_socat_path

var _socat_pid: int
var _stream_peer := StreamPeerUnix.new()


func _set_socket_path(path: String) -> void:
	socket_path = ProjectSettings.globalize_path(path)


func _get_socket_path() -> String:
	return ProjectSettings.localize_path(socket_path)


func _set_socat_path(path: String) -> void:
	socat_path = ProjectSettings.globalize_path(path)


func _get_socat_path() -> String:
	return ProjectSettings.localize_path(socat_path)


func _ready():
	var su = "su=%s" % user if user else ""
	var endpoint_1 = "unix-l:%s,keepalive,reuseaddr,fork,unlink-early" % socket_path
	var endpoint_2 = "exec:\"%s\",%s,pty,setsid,stderr,login,ctty" % [command, su]
	
	# Start a socat server that will open a shell when we connect to it's socket.
	_socat_pid = OS.execute(socat_path, [endpoint_1, endpoint_2], false)
	
	# Connect our StreamPeer to the socket. Beware of a race condition where _stream_peer
	# will try to connect to socket_path when socat hasn't created it yet.
	var err = _stream_peer.open(socket_path)
	if err != OK:
		var retries = MAX_RETRIES
		while err == ERR_FILE_NOT_FOUND and retries > 0:
			err = _stream_peer.open(socket_path)
			retries -= 1
		if err != OK:
			push_error("[Err %d. Could not connect shell to unix socket %s]" % [err, socket_path])


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


func send_data(data: PoolByteArray) -> void:
	if _stream_peer.get_status() == StreamPeerUnix.STATUS_CONNECTED:
		_stream_peer.put_data(data)


func _exit_tree():
	OS.execute("kill", ["-9", _socat_pid])
