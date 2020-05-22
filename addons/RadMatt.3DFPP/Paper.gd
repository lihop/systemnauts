extends MeshInstance


var held = false
var fullscreen = false


func _ready():
	visible = held
	$Details.visible = fullscreen


func pickup():
	held = true
	visible = true


func drop():
	visible = false
	held = false


func _process(delta):
	if not held:
		return
	
	if not $Details.visible and Input.is_mouse_button_pressed(BUTTON_RIGHT):
		visible = false
		$Details.visible = true
	elif $Details.visible and not Input.is_mouse_button_pressed(BUTTON_RIGHT):
		$Details.visible = false
		visible = true
