tool
class_name WorldGenerator
extends Node

const Maze = preload("res://systems/worldgen/Maze.cs")
const RoomAtlas = preload("res://systems/worldgen/RoomAtlas.cs")

enum Directions {
	NONE = 0,
	NORTH = 1 << 0,
	SOUTH = 1 << 1,
	EAST = 1 << 2,
	WEST = 1 << 3,
	UP = 1 << 4,
	DOWN = 1 << 5,
}

enum Transforms {
	NONE = 0,
	MIRROR_X = 1 << 0,
	MIRROR_Z = 1 << 1,
	ROTATE_90 = 1 << 2,
}

signal generated

export (Resource) var world_definition
export (bool) var debug = false
export (NodePath) var attach_to: NodePath = get_path()
export (bool) var generate = false setget set_generate  # Psuedo-button for in-editor world generation.


func set_generate(value):
	if value:
		generate()


static func print_directions(directions: int) -> void:
	var strings := PoolStringArray()

	if directions == Directions.NONE:
		strings.append("None")
	if directions & Directions.NORTH:
		strings.append("North")
	if directions & Directions.SOUTH:
		strings.append("South")
	if directions & Directions.EAST:
		strings.append("East")
	if directions & Directions.WEST:
		strings.append("West")
	if directions & Directions.UP:
		strings.append("Up")
	if directions & Directions.DOWN:
		strings.append("Down")

	print(strings.join(", "))

static func print_transforms(transforms: int) -> void:
	var strings := PoolStringArray()

	if transforms == Transforms.NONE:
		strings.append("None")
	if transforms & Transforms.MIRROR_X:
		strings.append("MirrorX")
	if transforms & Transforms.MIRROR_Z:
		strings.append("MirrorZ")
	if transforms & Transforms.ROTATE_90:
		strings.append("Rotate90")

	print(strings.join(", "))


func generate():
	var maze = Maze.New(world_definition.map_size)
	maze.FollowLastNodeRatio = world_definition.follow_last_node_ratio
	maze.HorizontalRatio = world_definition.horizontal_ratio
	maze.OpenLoopsRatio = world_definition.open_loops_ratio
	maze.Debug = debug
	maze.Generate()

	# Now we have a maze, start filling it with rooms.
	for child in get_node(attach_to).get_children():
		if child.get_meta("generated"):
			child.free()

	var room_atlas = RoomAtlas.New(world_definition.rooms)
	for mazeRoom in maze.Rooms:
		var room = room_atlas.GetRandomRoomWithExits(mazeRoom.Exits)
		if room == null:
			push_error(
				"Aborting: Cannot find suitable rooms to build this world. Do you need to add more rooms to the world definition?"
			)
			return
		else:
			var room_map: Spatial

			if room.Filename.ends_with(".map"):
				room_map = QodotMap.new()
				room_map.inverse_scale_factor = 64
				room_map.map_file = room.Filename
				get_node(attach_to).add_child(room_map, true)
				room_map.verify_and_build()
				yield(room_map, "build_complete")
				yield(get_tree().create_timer(0.5), "timeout")
			elif room.Filename.ends_with(".tscn"):
				room_map = load(room.Filename).instance()
				get_node(attach_to).add_child(room_map, true)

			room_map.set_meta("generated", true)
			room_map.set_owner(get_tree().edited_scene_root)
			room_map.global_transform.origin = Vector3(12, 8, 12) * mazeRoom.Coords

			if room.Transforms == Transforms.NONE:
				continue
			if room.Transforms & Transforms.MIRROR_X:
				room_map.global_transform *= Transform.FLIP_Z
			if room.Transforms & Transforms.MIRROR_Z:
				room_map.global_transform *= Transform.FLIP_X
			if room.Transforms & Transforms.ROTATE_90:
				room_map.rotate_y(deg2rad(90))

			room_map.owner = get_tree().edited_scene_root

	emit_signal("generated")
