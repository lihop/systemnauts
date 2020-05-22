extends Node
class_name Commander


signal data_received(data)

var stream_peer = StreamPeerTCP.new()


func _ready():
	# Running socat manually for now.
	var err = stream_peer.connect_to_host("127.0.0.1", 1747)
	if err != OK:
		print("Couldn't connect commander stream peer!")


func run_command(data: String) -> void:
	# We need to ensure commands end in LF
	data += "\n"
	stream_peer.put_data(data.to_ascii())


func write(data: PoolByteArray) -> void:
	stream_peer.put_data(data)


func _process(delta):
	if stream_peer.is_connected_to_host():
		var res = stream_peer.get_data(stream_peer.get_available_bytes())
		var error = res[0]
		var data = res[1]
		if error != OK:
			print("Error getting data")
		elif not data.empty():
			emit_signal("data_received", data)
