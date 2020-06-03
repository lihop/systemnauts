extends Node


signal data_received(data)

var stream_peer_unix: StreamPeerUnix
var path = ProjectSettings.globalize_path("user://projector.sock")


func _ready():
	stream_peer_unix = StreamPeerUnix.new()
	stream_peer_unix.open(path)


func _process(delta):
	if stream_peer_unix.get_status() == StreamPeerUnix.STATUS_CONNECTED:
		var available_bytes = stream_peer_unix.get_available_bytes()
		
		if available_bytes > 0:
			var data = stream_peer_unix.get_data(available_bytes)
			emit_signal("data_received", data[1].get_string_from_utf8())


func _exit_tree():
	stream_peer_unix.close()
