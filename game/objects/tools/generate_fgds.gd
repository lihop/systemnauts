tool
extends Spatial

export (String, FILE, "*.tres") var fgd_file
export (Array, String, DIR) var directories
export (bool) var run := false setget set_run


func set_run(value):
	run()


func run():
	var fgd_res = load(fgd_file)
	fgd_res.entity_definitions = []

	for path in directories:
		var dir := Directory.new()
		dir.open(path)
		dir.list_dir_begin(true)
		while true:
			var file: String = dir.get_next()
			if file == "":
				break
			if not dir.current_is_dir():
				var src = "%s/%s" % [path, file]

				# Add materials for use by Qodot and entity OBJ models in Trenchbroom.
				if file.ends_with(".material"):
					var target_dir = "res://textures/"
					var material: SpatialMaterial = load("%s/%s" % [path, file])
					var material_name = file.trim_suffix(".material")
					var image := Image.new()

					if material.albedo_texture:
						image = material.albedo_texture.get_data()
					elif material.albedo_color:
						image.create(64, 64, false, Image.FORMAT_RGB8)
						image.fill(material.albedo_color)

					image.save_png(target_dir + material_name + ".png")
					dir.copy(src, target_dir + file)
					print("%s and preview saved to %s" % [file, target_dir + file])

				# Create and add FGD.
				if file.ends_with(".obj") or file.ends_with(".tscn"):
					if file.ends_with(".obj"):
						# Prefer tscn file if one exists.
						var check = File.new()
						var tscn = file.replace(".obj", ".tscn")
						if check.file_exists(tscn):
							print("Skipping %s in favor of %s" % [src, tscn])
							continue

					var object_name = file.trim_suffix(".obj").trim_suffix(".tscn")
					var scene: PackedScene = load(src)
					if not scene:
						push_warning("Skipping .obj file which is not imported as a scene.")

					var instance: Spatial = scene.instance()
					var aabb: AABB

					for child in instance.get_children():
						if child is RigidBody:
							for grandchild in child.get_children():
								if grandchild is MeshInstance:
									aabb = grandchild.get_aabb()

					if aabb:
						var fgd := QodotFGDPointClass.new()
						fgd.classname = object_name.capitalize().replace(" ", "_")
						fgd.meta_properties["mangle"] = Vector3(0, 0, 0)

						fgd.meta_properties["color"] = Color.saddlebrown

						var max_xz = abs(max(aabb.size.x * 32, aabb.size.z * 32))
						var size_y = abs(aabb.size.y * 32)

						# Round up to the nearest 1/8 so it can fit nicely on the grid.
						max_xz = ceil(max_xz * 8) / 8
						size_y = ceil(size_y * 8) / 8

						var size = Vector3(max_xz, max_xz, size_y)
						var position = Vector3(-max_xz, -max_xz, -size_y)

						fgd.meta_properties["size"] = AABB(position, size)
						fgd.meta_properties["model"] = (
							'"%s"'
							% src.trim_prefix("res://").replace(".tscn", ".obj")
						)
						fgd.node_class = "QodotEntity"
						fgd.scene_file = scene
						fgd.script_class = preload("../entity.gd")

						var target = src.replace(".obj", "_fgd.tres").replace(".tscn", "_fgd.tres")
						ResourceSaver.save(target, fgd)
						var fgd_reloaded = load(target)
						fgd_res.entity_definitions.append(fgd_reloaded)

						print("%s FGD generated" % file)

	ResourceSaver.save(fgd_file, fgd_res)
