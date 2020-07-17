extends WorldEnvironment


func _process(delta):
	var text = "Godot is awesome!"
	if $Label3D.text != text:
		$Label3D.call_deferred("set_text", text)
