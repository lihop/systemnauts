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
						worldspawn_layers.append(layer_mesh_instance)

			if worldspawn:
				mesh_instances.append(worldspawn)
			if not worldspawn_layers.empty():
				mesh_instances.append_array(worldspawn_layers)

	match mesh_instances.size():
		0:
			return _abort_baking("No suitable MeshInstance(s) found.")
		1:
			mesh_instance = mesh_instances[0].duplicate()
		_:
			var splerger = Splerger.new()
			mesh_instance = splerger.merge_meshinstances(mesh_instances, get_parent(), false, false)

	# Step 3. Initialize navigation using MeshInstance and Parameters.

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


#
#	var mesh = _mesh if _mesh else Mesh.new()
#	var navmesh_params := _navmesh_params if _navmesh_params else []
#	var navigation_areas = _navigation_areas if _navigation_areas else []
#
#	if not mesh or navmesh_params.empty() or navigation_areas.empty():
#		var err_msg := "Cannot initialize navigation:"
#		if not mesh:
#			err_msg += "\n\nNo mesh."
#		if navmesh_params.empty():
#			err_msg += "\n\nNo navmesh params."
#		if navigation_areas.empty():
#			err_msg += "\n\nNo navigation areas."
#
#	var mesh_instance = MeshInstance.new()
#	mesh_instance.mesh = mesh
#
#	var nav_params = DetourNavigationParameters.new()
#	nav_params.ticksPerSecond = ticks_per_second
#	nav_params.maxObstacles = max_obstacles
#	nav_params.navMeshParameters = nav_params
#
#	navigation = DetourNavigationNative.new()
#	navigation.initialize(mesh_instance, nav_params)

#export(NodePath) var qodot_map
#export(int) var ticks_per_second := 60 # How often the navigation is updated per second in its own thread
#export(int) var max_obstacles := 256 # How many dynamic obstacles can be present at the same time
#export(Mesh) var mesh
#export(Array, Resource) var navigation_areas


#var navigation = _DetourNavigation.new()
#
#func _bake_navigation():
#	pass
#
#
#onready var map: QodotMap = get_node(qodot_map)
#
#
#func _ready():
#	var nav_params = _get_nav_params()
##	if map is QodotMap and _mesh is Mesh and navParams is DetourNavigationMeshParameters:
##		_init_navigation(map, _mesh, navParams)
#
#
##func _get_property_list():
##	var properties := []
##	properties.append({
##		name = "mesh",
##		type = TYPE_OBJECT,
##		usage = PROPERTY_USAGE_STORAGE
##	})
##	return properties
#
#
#func _init_navigation(map) -> void:
#	var nav_params = _get_nav_params()
#	#var markers = _get_markers()
#	var mesh_instance = _get_mesh_instance()
#
#
#func _get_nav_params():
#	var nav_params := DetourNavigationParameters.new()
#	nav_params.ticksPerSecond = ticks_per_second
#	nav_params.maxObstacles = max_obstacles
#
#	# Create the parameters for each navmesh.
#	for child in get_children():
#		if child is DetourNavigationMeshInstance and child.navmesh:
#			var navmesh_params := DetourNavigationMeshParameters.new()
#			var resource := Resource.new()
#			for property in child.navmesh.get_property_list():
#				if property.name in navmesh_params and not property.name in resource:
#					navmesh_params.set(property.name, child.navmesh.get(property.name))
#			#navParams.navMeshParameters.append(navmesh_params)
#
#	#return nav_params
#
#
#func _get_mesh_instance():
#	var meshes := []
#
#	if meshes.size() == 1:
#		return meshes[0]
#	elif meshes.size() >= 2:
#		return
#	else:
#		return null
#
#
#func _add_meshes_for_map(meshes: Array, map: QodotMap):
#
#	var mesh_instance := MeshInstance.new()
#	#var map = get_node(qodot_map)
#
#	var splerger = Splerger.new()
#	var entity_mesh_instances = map.entity_mesh_instances.values()
#
#	var worldspawn = map.get_node_or_null("entity_0_worldspawn/entity_0_mesh_instance")
#	var layers = map.worldspawn_layer_mesh_instances.values()
#
#	if worldspawn:
#		layers.append(worldspawn)
#
#	#var mesh_instance: MeshInstance
#
#	if layers.size() == 1:
#		mesh_instance = layers[0].duplicate()
#	elif layers.size() > 1:
#		mesh_instance = splerger.merge_meshinstances(layers, get_parent(), false, false)
#	else:
#		push_error("Could not find suitable MeshInstance(s) for generating navigation mesh.")
#		return
#
#	# Initialize the navigation with the mesh instance and the parameters.
#	#navigation.initialize(mesh_instance, navParams)
#	mesh_instance.queue_free()
#
#
#func _build_areas():
#	for layer in map.worldspawn_layers:
#		var entity = map.get_node("entity_0_%s" % layer.name)
#		var collision_shapes = []
#		for child in entity.get_children():
#			if child is CollisionShape:
#				collision_shapes.append(child)
#
#		for collision_shape in collision_shapes:
#			var shape = collision_shape.shape
#			var points = shape.get_points()
#
#			# Create an AABB around points of the shape.
#			var aabb = AABB(points[0], Vector3.ZERO)
#			for point in points:
#				aabb = aabb.expand(point)
#
#			var vertices := []
#			vertices.append(aabb.get_endpoint(0))
#			vertices.append(aabb.get_endpoint(4))
#			vertices.append(aabb.get_endpoint(5))
#			vertices.append(aabb.get_endpoint(1))
#
#			var marker_id = navigation.markConvexArea(vertices, 6, layer.area_type)
#
#
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


#func _build_navigation():
#	pass
#
#
#func _load_navigation():
#	#var nav_params := _get_nav_params()
#
#	var mesh_instance := MeshInstance.new()
#	mesh_instance.mesh = mesh
#
#	#navigation.initialize(mesh_instance, navParams)
#
#	_generate_debug_meshes()
#	#_generate_areas()
#
#
##func _ready():
##	map: QodotMap = get_node(qodot_map)
##	print(navigation)
##	_generate_debug_meshes()
#
#
##func _on_Map_build_complete():
##	if get_node(qodot_map) is QodotMap:
##		_bake_navmesh()
#
#


func _get_property_list():
	return [
		{
			name = "_num_nav_meshes",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
		}
	]


#
#
#class NavigationMeshArea:
#	extends Resource
#
#	export(Array) var vertices
#	export(float) var height
#	export(NavigableWorldspawnLayer.AreaType) var type
#
#
#	func _init(p_vertices := [], p_height := 6, p_type = NavigableWorldspawnLayer.AREA_TYPE_GROUND):
#		vertices = p_vertices
#		height = p_height
#		type = p_type


func bake_navmesh():
	pass  # Replace with function body.


func add_agent(agent: BaseCharacter):
	var params = DetourCrowdAgentParameters.new()
	params.position = agent.global_transform.origin * Vector3(1, 0.5, 1)
	params.radius = 0.7
	params.height = 1.6
	params.maxAcceleration = 6.0 * 10
	params.maxSpeed = 3.0 * 10
	params.filterName = "default"
	params.anticipateTurns = true
	params.optimizeVisibility = true
	params.optimizeTopology = true
	params.avoidObstacles = true
	params.avoidOtherAgents = true
	params.obstacleAvoidance = 1
	params.separationWeight = 1.0
	var nav_agent = navigation.addAgent(params)
	return nav_agent


func remove_agent(agent: AIAgent):
	navigation.removeAgent(agent.nav_agent)
	agent.nav_agent = null
