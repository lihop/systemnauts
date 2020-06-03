extends Sprite3D


func _ready():
	$StreamPeerUnix.connect("data_received", $Viewport/Terminal, "write")
	texture = $Viewport.get_texture()
