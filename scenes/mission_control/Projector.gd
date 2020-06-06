extends Sprite3D
class_name Projector


export(bool) var enabled = true
export(Vector2) var size := Vector2(1024, 768)


func _ready():
	region_rect = Rect2(Vector2(0, 0), size)
	
	if enabled:
		$StreamPeerUnix.connect("data_received", $Viewport/Terminal, "write")
		texture = $Viewport.get_texture()
	else:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(0, 0, 0))
		gradient.set_color(1, Color(0, 0, 0))
		
		var gradient_texture = GradientTexture.new()
		gradient_texture.gradient = gradient
		
		texture = gradient_texture
