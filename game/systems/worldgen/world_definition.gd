tool
class_name WorldGenDefinition
extends Resource

enum Direction {
	NONE = 0,
	NORTH = 1 << 1,
	SOUTH = 1 << 2,
	EAST = 1 << 3,
	WEST = 1 << 4,
	UP = 1 << 5,
	DOWN = 1 << 6,
}

enum RoomTransform {
	NONE = 0,
	MIRROR_X = 1 << 1,
	MIRROR_Z = 1 << 2,
	ROTATE_90 = 1 << 3,
}

const MAX_TRANSFORM = (
	RoomTransform.NONE
	| RoomTransform.MIRROR_X
	| RoomTransform.MIRROR_Z
	| RoomTransform.ROTATE_90
)

export (String) var rng_seed := ""
export (Vector3) var map_size := Vector3(4, 2, 4) setget set_map_size
export (float) var follow_last_node_ratio := 0.5
export (float) var horizontal_ratio := 0.75
export (float) var open_loops_ratio := 0.2
export (Array, String, FILE, "*.map") var feature_rooms := Array()
export (Array, String, DIR) var room_directories := Array()

var rooms := Array() setget , get_rooms
var room_defs := Array()
var exits_map := Dictionary()

var _exits_regex := RegEx.new()

var _rooms_hash: int
var _rooms := Array()


func set_map_size(value):
	map_size = Vector3(int(value.x), int(value.y), int(value.z))


func set_rooms(value):
	rooms = value


func get_rooms() -> Array:
	var rooms_hash = hash(room_directories.hash() + rooms.hash())

	if _rooms_hash == rooms_hash:
		return _rooms

	_rooms_hash = rooms_hash
	_rooms = Array()

	for directory in room_directories:
		var dir := Directory.new()
		dir.open(directory)
		dir.list_dir_begin(true)
		while true:
			var file: String = dir.get_next()
			if file == "":
				break
			elif not dir.current_is_dir() and (file.ends_with(".map") or file.ends_with(".tscn")):
				_rooms.append("%s/%s" % [directory, file])

	_rooms.append_array(rooms)

	return _rooms


func _init(
	p_rng_seed := "",
	p_map_size := Vector3(4, 2, 4),
	p_follow_last_node_ratio := 0.5,
	p_horizontal_ratio := 0.75,
	p_open_loops_ratio := 0.2,
	p_feature_rooms := [],
	p_rooms := []
):
	map_size = p_map_size
	follow_last_node_ratio = follow_last_node_ratio
	horizontal_ratio = p_horizontal_ratio
	open_loops_ratio = p_open_loops_ratio
	feature_rooms = p_feature_rooms
	rooms = p_rooms


func get_exits(filename: String) -> int:
	if not _exits_regex.get_pattern():
		assert(_exits_regex.compile("(?<exit_chars>[nsewudx]{1,6}).map$") == OK)

	var exits = Direction.NONE

	var matches = _exits_regex.search_all(filename)
	for m in matches:
		var exit_chars = m.get_string(1)
		for i in range(exit_chars.length()):
			var exit_char: String = exit_chars[i]
			match exit_char:
				"n":
					exits |= Direction.NORTH
				"e":
					exits |= Direction.EAST
				"s":
					exits |= Direction.SOUTH
				"w":
					exits |= Direction.WEST
				"u":
					exits |= Direction.UP
				"d":
					exits |= Direction.DOWN
				"x":
					exits |= Direction.NONE
				_:
					push_warning("Unrecognized exit_char %s, using Exit.NONE" % exit_char)
					exits |= Direction.NONE

	return exits


func rand_room_with_exits(exits: int):
	var rooms = exits_map.get(exits, [])
	return null if rooms.empty() else rooms[randi() % rooms.size()]
