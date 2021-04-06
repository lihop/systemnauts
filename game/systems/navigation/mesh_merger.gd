# Used to merge multiple MeshInstances of QodotMaps for use by TheSHEEEP's
# godotdetour navigation library.
#
# It can be used with meshes that have been mirrored. Such meshes need to
# have a "mirrored" metadata entry.
#
# Based on https://gist.github.com/d3is/6bddc5b88570366cbf23afaf191577e2
# which is in turn based on https://github.com/lawnjelly/godot-splerger but
# modified to support multiple surfaces.
tool
class_name MeshMerger
extends Reference

static func merge_mesh_instances(mesh_instances := [], use_local_space := false) -> MeshInstance:
	var combined_mesh_instance := MeshInstance.new()
	var temp_mesh := ArrayMesh.new()
	var surface_tool := SurfaceTool.new()
	var vertex_count := 0

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for mesh_instance in mesh_instances:
		vertex_count = _merge_mesh_instance(
			surface_tool, mesh_instance, vertex_count, use_local_space
		)

	#surface_tool.generate_normals(true)
	surface_tool.commit(temp_mesh)
	combined_mesh_instance.mesh = temp_mesh

	return combined_mesh_instance

static func _merge_mesh_instance(
	surface_tool: SurfaceTool,
	mesh_instance: MeshInstance,
	vertex_count: int,
	use_local_space := false
) -> int:
	var mesh: Mesh = mesh_instance.mesh
	var mdt := MeshDataTool.new()
	var surface_count: int = mesh.get_surface_count()

	for surface in range(surface_count):
		mdt.create_from_surface(mesh, surface)

		var n_verts: int = mdt.get_vertex_count()
		var n_faces: int = mdt.get_face_count()
		var global_transform: Transform = mesh_instance.global_transform

		for v in range(n_verts):
			var vert: Vector3 = mdt.get_vertex(v)
			var normal: Vector3 = mdt.get_vertex_normal(v)

			if not use_local_space:
				vert = global_transform.xform(vert)

			surface_tool.add_vertex(vert)

		for f in range(n_faces):
			# Mirrored meshes need to be processed in reverse order.
			for i in range(2, -1, -1) if mesh_instance.has_meta("mirrored") else range(3):
				var ind: int = mdt.get_face_vertex(f, i)
				surface_tool.add_index(ind + vertex_count)

		vertex_count += n_verts

	return vertex_count
