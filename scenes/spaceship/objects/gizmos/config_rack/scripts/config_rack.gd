extends Spatial

const BlueprintMaterial = preload("../materials/blueprint_material.tres")
const SlotScript = preload("./slot.gd")

const DIRECTORY_SLOTS = 8
const FILE_SLOTS = 32

func _ready():
	# Loop through slot meshes and replace their material with the transparent
	# one.
	
	for i in range(DIRECTORY_SLOTS):
		var mesh: MeshInstance = get_node("config_rack/directory_slot_%d" % i)
		mesh.set_surface_material(0, BlueprintMaterial)
		mesh.set_surface_material(1, BlueprintMaterial)
		
		var collision = mesh.get_node("static_collision")
		collision.set_script(SlotScript)
		collision.slot_type = SlotScript.SLOT_TYPES.DIRECTORY
	
	for i in range(FILE_SLOTS):
		var mesh: MeshInstance = get_node("config_rack/file_slot_%d" % i)
		mesh.set_surface_material(0, BlueprintMaterial)
		
		var collision = mesh.get_node("static_collision")
		collision.set_script(SlotScript)
		collision.slot_type = SlotScript.SLOT_TYPES.FILE
