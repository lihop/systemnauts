extends Spatial


export(Color) var color = $tile.mesh.surface_get_material(0).emission


func _ready():
	var material: SpatialMaterial = $tile.mesh.surface_get_material(0).duplicate()
	$tile.set_surface_material(0, material)
	material.emission = color
	$tile.set_surface_material(0, material)
