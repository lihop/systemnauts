extends StaticBody


signal pressed()


func ready():
	pass


func interact(relate):
	emit_signal("pressed")
	
	var paper = relate.find_node("Paper")
	paper.drop()
	$AudioStreamPlayer3D.play(0.5)
	$AnimationPlayer.play("press")
	
	var res = HTTPResponse.new()
	res.status = 200
	res.headers = {
		"Connection": "keep-alive",
		"Date": "{weekday}, {day} {month} {year} {hour}:{minute}:{second} GMT" \
				.format(OS.get_datetime(true)),
		# TODO: "ETag"
		"X-Powered-By": "Godot",
	}
	
	# Collect files in the send area!
	var body = PoolByteArray([])
	var paths = []
	OS.execute("bash", ["-c", "\"'ls -1 -d /home/leroy/tmp/test/out/*'\""], true, paths)

	for path in paths:
		var file = File.new()
		var err = file.open(path.trim_suffix("\n"), File.READ)
		if err != OK:
			push_error("Error opening file %s" % path)
		else:
			print("Path: ", path.trim_suffix("\n"))
			print("File len: ", file.get_len())
			body.append_array(file.get_buffer(file.get_len()))
			print("Body len: ", body.size())
	
	res.headers["Content-Length"] = body.size()
	
	add_child(res)
	res.send(body)
