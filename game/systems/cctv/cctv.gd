class_name CCTV
extends Node


func _ready():
	return  # Disable until we can make this not cause lag (i.e. run in seperate thread).
	while true:
		if OS.has_feature("Server"):
			# Server doesn't have graphics card so can't "see" anything.
			return

		var cctv_cameras = get_tree().get_nodes_in_group("cctv_cameras")
		for camera in cctv_cameras:
			var image: Image = camera.take_photo()
			var raw_data = image.save_png_to_buffer()

			if (
				multiplayer.network_peer
				and (
					multiplayer.network_peer.get_connection_status()
					== NetworkedMultiplayerPeer.CONNECTION_CONNECTED
				)
			):
				rpc_id(Server.SERVER_ID, "save_image", raw_data, camera.name)

		yield(get_tree().create_timer(5), "timeout")


master func save_image(raw_data: PoolByteArray, cam_name := "cctv.png") -> void:
	var file := File.new()
	file.open("/var/www/html/%s.png" % cam_name, File.WRITE)
	file.store_buffer(raw_data)
	file.close()
