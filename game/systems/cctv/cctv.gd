class_name CCTV
extends Node


func _ready():
	while true:
		if OS.has_feature("Server"):
			# Server doesn't have graphics card so can't "see" anything.
			return

		var cctv_cameras = get_tree().get_nodes_in_group("cctv_cameras")
		if not cctv_cameras.empty():
			var camera = cctv_cameras[0]
			var image: Image = camera.take_photo()
			#image.save_png("/tmp/cctv.png")
			var raw_data = image.save_png_to_buffer()

			if (
				multiplayer.network_peer.get_connection_status()
				== NetworkedMultiplayerPeer.CONNECTION_CONNECTED
			):
				rpc_id(Server.SERVER_ID, "save_image", raw_data)

		yield(get_tree().create_timer(5), "timeout")


master func save_image(raw_data: PoolByteArray) -> void:
	var file := File.new()
	file.open("/var/www/html/cctv.png", File.WRITE)
	file.store_buffer(raw_data)
	file.close()
