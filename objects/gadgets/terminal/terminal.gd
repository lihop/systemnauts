extends Spatial


func _ready():
	$Viewport/TestTerminal.rect_size = $Viewport.size


func _input(event):
	if event is InputEventKey:
		$Viewport.input(event)
