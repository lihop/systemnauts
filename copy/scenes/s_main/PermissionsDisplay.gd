extends MeshInstance


onready var label = $Viewport/Label


func _ready():
	set_text("----------")
	
	var material = SpatialMaterial.new()
	material.flags_transparent = true
	material.flags_unshaded = true
	material.albedo_texture = $Viewport.get_texture()
	set_surface_material(0, material)


func set_text(text: String) -> void:
	label.text = text


func set_color(color: Color) -> void:
	label.set("custom_colors/font_color", color)
