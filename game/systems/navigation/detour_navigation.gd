tool
class_name DetourNavigation, "icon_navigation.svg"
extends Spatial

const NAVIGATION_RESOURCE_WARNING := "A DetourNavigation resource must be set or created for this node to work."

const DetourNavigationNative: NativeScript = preload("res://addons/godotdetour/detournavigation.gdns")
const DetourNavigationParameters: NativeScript = preload("res://addons/godotdetour/detournavigationparameters.gdns")
const DetourNavigationMeshNative: NativeScript = preload("res://addons/godotdetour/detournavigationmesh.gdns")
const DetourNavigationMeshParameters: NativeScript = preload("res://addons/godotdetour/detournavigationmeshparameters.gdns")
const DetourCrowdAgent: NativeScript = preload("res://addons/godotdetour/detourcrowdagent.gdns")
const DetourCrowdAgentParameters: NativeScript = preload("res://addons/godotdetour/detourcrowdagentparameters.gdns")

# Psuedo-button.
export (bool) var BakeNavigation setget _bake_navigation

export (int) var ticks_per_second := 60
export (int) var max_obstacles := 256

var navigation := DetourNavigationNative.new()

var _num_nav_meshes: int = 0


func get_class() -> String:
	return "DetourNavigation"


func _get_nav_file() -> String:
	var scene_file := (
		get_tree().edited_scene_root.filename
		if Engine.is_editor_hint()
		else get_tree().current_scene.filename
	)
	return scene_file.replace(".tscn", ".nav.bin").replace(".scn", ".nav.bin")


func _ready():
	if Engine.is_editor_hint():
		set_process(false)  # Don't run navigation thread in editor.

	if Directory.new().file_exists(_get_nav_file()):
		navigation = DetourNavigationNative.new()
		navigation.load(_get_nav_file(), true)
		_setup_debug_meshes()


func _setup_debug_meshes() -> void:
	var index := 0
	for child in get_children():
		if child is DetourNavigationMeshInstance:
			var navmesh: DetourNavigationMeshInstance = child
			if index < _num_nav_meshes:
				if navmesh.is_connected("debug_toggled", self, "_on_navmesh_debug_toggled"):
					navmesh.disconnect("debug_toggled", self, "_on_navmesh_debug_toggled")
				var _connection = navmesh.connect(
					"debug_toggled", self, "_on_navmesh_debug_toggled", [navmesh, index]
				)

				if navmesh.debug:
					_on_navmesh_debug_toggled(true, navmesh, index)
			index += 1


func _abort_baking(message: String) -> void:
	push_error("Navigation baking aborted: %s" % message)


func _bake_navigation(value := true):
	if value:
		bake_navigation()


func bake_navigation():
	if not Engine.is_editor_hint():
		return _abort_baking("Navigation can only be baked in the editor.")

	navigation = DetourNavigationNative.new()
	_num_nav_meshes = 0

	# Step 1. Generate Parameters.

	var nav_params := DetourNavigationParameters.new()
	nav_params.ticksPerSecond = ticks_per_second
	nav_params.maxObstacles = max_obstacles

	for child in get_children():
		if child is DetourNavigationMeshInstance and child.navmesh:
			var navmesh_params := DetourNavigationMeshParameters.new()
			var resource := Resource.new()
			for property in child.navmesh.get_property_list():
				if property.name in navmesh_params and not property.name in resource:
					navmesh_params.set(property.name, child.navmesh.get(property.name))
			nav_params.navMeshParameters.append(navmesh_params)
			_num_nav_meshes += 1

	if nav_params.navMeshParameters.empty():
		return _abort_baking("No navmesh parameters found.")

	# Step 2. Generate MeshInstance.

	var mesh_instance: MeshInstance
	var mesh_instances := []

	for child in get_children():
		if child is QodotMap:
			var map: QodotMap = child
			var mirrored: bool = child.scale != Vector3.ONE
			var worldspawn: MeshInstance = map.get_node_or_null(
				"entity_0_worldspawn/entity_0_mesh_instance"
			)
			var worldspawn_layers := []

			for layer in map.worldspawn_layers:
				for entity in map.get_children():
					var layer_mesh_instance: MeshInstance = entity.get_node_or_null(
						"entity_0_%s_mesh_instance" % layer.name
					)
					if layer_mesh_instance:
						layer_mesh_instance.set_meta("mirrored", mirrored)
						worldspawn_layers.append(layer_mesh_instance)

			if worldspawn:
				worldspawn.set_meta("mirrored", mirrored)
				mesh_instances.append(worldspawn)
			if not worldspawn_layers.empty():
				mesh_instances.append_array(worldspawn_layers)

	match mesh_instances.size():
		0:
			return _abort_baking("No suitable MeshInstance(s) found.")
		1:
			mesh_instance = mesh_instances[0].duplicate()
		_:
			print(mesh_instances)
			mesh_instance = MeshMerger.merge_mesh_instances(mesh_instances)

	# Step 3. Initialize navigation using MeshInstance and Parameters

	navigation = DetourNavigationNative.new()
	navigation.initialize(mesh_instance, nav_params)
	mesh_instance.queue_free()

	# Step 4. Generate and add Areas.

	for child in get_children():
		if child is QodotMap:
			var map: QodotMap = child
			for layer in map.worldspawn_layers:
				var entity = map.get_node("entity_0_%s" % layer.name)
				var collision_shapes = []
				for entity_child in entity.get_children():
					if entity_child is CollisionShape:
						collision_shapes.append(entity_child)

				for collision_shape in collision_shapes:
					var shape = collision_shape.shape
					var points = shape.get_points()

					# Create an AABB around points of the shape.
					var aabb := AABB(collision_shape.to_global(points[0]), Vector3.ZERO)

					for point in points:
						aabb = aabb.expand(collision_shape.to_global(point))

					var vertices := []
					vertices.append(aabb.get_endpoint(0))
					vertices.append(aabb.get_endpoint(4))
					vertices.append(aabb.get_endpoint(5))
					vertices.append(aabb.get_endpoint(1))

					var _marker_id = navigation.markConvexArea(vertices, 6, layer.area_type)

	# Step 5. Generate and add Portals.

	# TODO.

	# Step 6. Save navigation to file.

	var nav_file = _get_nav_file()

	if navigation.save(nav_file, true):
		print("DetourNavigation data saved to '%s'." % nav_file)
	else:
		push_warning("DetourNavigation data not saved.")

	# Step 7. Generate Debug MeshInstances.

	_setup_debug_meshes()


func _on_navmesh_debug_toggled(
	debug_enabled: bool, navmesh: DetourNavigationMeshInstance, index: int
):
	if navmesh != null:
		if (
			navmesh.debug_mesh_instance is MeshInstance
			and navmesh.debug_mesh_instance.is_inside_tree()
		):
			navmesh.debug_mesh_instance.free()

		if debug_enabled:
			# Create the debug mesh.
			# First parameter is the index of the navigation mesh (in case there are multiple).
			# Second parameter is if you want to display the cache boundaries or not (false will only display the navmesh itself, which is likely what most want).
			var mesh_instance = navigation.createDebugMesh(index, false)

			if not mesh_instance:
				push_error("Could not generate debug mesh instance for %s." % navmesh.name)
				navmesh.disconnect("debug_toggled", self, "_on_navmesh_debug_toggled")
				return

			# Scale and raise the debug mesh instance a little elevated to avoid z-fighting.
			mesh_instance.scale = Vector3(1.001, 1.001, 1.001)
			mesh_instance.translation = Vector3(-0.03, 0.05, 0.03)

			navmesh.debug_mesh_instance = mesh_instance
			navmesh.add_child(mesh_instance)


func _get_property_list():
	return [
		{
			name = "_num_nav_meshes",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
		}
	]


func add_agent(params):
	return navigation.addAgent(params)


func remove_agent(agent):
	navigation.removeAgent(agent)
