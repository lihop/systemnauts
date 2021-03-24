# This code is based on the world generation code of the game Eldritch (https://www.eldritchgame.com/)
# by David Pittman (https://www.dphrygian.com/) and Minor Key Games (https://www.minorkeygames.com/).
# 
# The Eldritch source code is available at https://www.eldritchgame.com/about.html#source and is
# released under the following license:
#
# /* ---------------------------------------------------------------- */
#
# Copyright © 2013-2019 Minor Key Games, LLC
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#   misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#
# /* ---------------------------------------------------------------- */

tool
class_name WorldGen
extends Spatial

const ROOM_WIDTH = 12
const ROOM_LENGTH = 12
const ROOM_HEIGHT = 8

export(int) var width := 4
export(int) var height := 4
export(int) var length := 4

export(int) var map_size_x := 4
export(int) var map_size_y := 4
export(int) var map_size_z := 4

var expansion_horizontal_ratio := 0.0
var expansion_follow_last_node_ratio := 0.0
var expansion_open_loops_ratio := 0.0

var unopen_room_set := Dictionary()
var open_room_set := Dictionary()
var open_room_stack := []
var closed_room_set := Dictionary()
var locked_room_set := Dictionary()

var exit_transforms := Array()

var num_rooms

var room_defs := Array() # *All* room defs, even those also tracked as start rooms, etc.

export(bool) var debug := false

enum Direction {
	NONE = 0,
	NORTH = 1,
	SOUTH = 1 << 1,
	EAST = 1 << 2,
	WEST = 1 << 3,
	UP = 1 << 4,
	DOWN = 1 << 5,
}

enum RoomExit {
	NONE = 0x00
	NORTH = 0x01
	SOUTH = 0x02
	EAST = 0x04
	WEST = 0x08
	UP = 0x10
	DOWN = 0x20
}

export(Direction, FLAGS) var dir setget set_dir

func set_dir(val):
	dir = val
	print(val)

enum RoomTransform {
	NONE = 0x0
	MIRROR_X = 0x1
	MIRROR_Y = 0x2
	ROTATE_90 = 0x4
}

export(bool) var build setget build

const max_exits = 1 + (RoomExit.NORTH | RoomExit.SOUTH | RoomExit.EAST | RoomExit.WEST | RoomExit.UP | RoomExit.DOWN)
const max_transforms = 1 + (RoomTransform.MIRROR_X | RoomTransform.MIRROR_Y | RoomTransform.ROTATE_90)

export(Resource) var world_gen_def


class OpenLoopOpportunity:
	var room_index: int
	var exit: int
	var neighbors: NeighborIndices

var feature_room_defs := Array()
var generated_rooms := Array()


var simming_generation: bool

var room_map := Dictionary()

var themes := Array()
var theme_bias := 0.0


func build(val):
	if val:
		initialize(world_gen_def)
		generate()


func _ready():
	randomize()
	initialize(world_gen_def)
	generate()
	#add_rooms_to_map()


func generate_old():
	var map := {}
	var closed_rooms := []
	var open_rooms := []
	var total_rooms := width * height * length
	
	for x in range(width):
		for y in range(height):
			for z in range(length):
				closed_rooms.append(Vector3(x, y, z))
	
	var start_room = closed_rooms[randi() % closed_rooms.size()]
	closed_rooms.erase(start_room)
	open_rooms.append(start_room)
	map[start_room] = 0
	
	while not open_rooms.empty():
		var open_room: Vector3 = open_rooms[randi() % open_rooms.size()]
		
		var neighbors: Array = get_neighbors(open_room)
		neighbors.shuffle()
		
		for neighbor in neighbors:
			if closed_rooms.has(neighbor):
				closed_rooms.erase(neighbor)
				open_rooms.append(neighbor)
				
				map[neighbor] = get_direction(neighbor, open_room)
				map[open_room] |= get_direction(open_room, neighbor)
				
				continue
		
		open_rooms.erase(open_room)
		
	var room_dictionary = get_room_dictionary()
	
	for child in get_children():
		child.queue_free()
	


func add_rooms_to_map():
	for z in range(map_size_z - 1, -1, -1): # Print top to bottom
		for y in range(map_size_y - 1, -1, -1): # Print north to south
			for x in range(map_size_x): # Print west to east
				var room_index = get_room_index(x, y, z)
				var room = generated_rooms[room_index]
				print(room)
				return
#				var data = room_dictionary[map[cell]]
#				var room_map = load("res://gen_room_map.gd").new()
#				room_map.inverse_scale_factor = 64
#				room_map.map_file = "res://rooms/min/%s" % data.file
#				add_child(room_map)
#				room_map.owner = get_tree().edited_scene_root
#				room_map.global_transform.origin = cell * Vector3(13, 9, 13)
#				room_map.verify_and_build()
#				yield(room_map, "build_complete")
		#room_map.apply_transform(data.room_transform)w

#	var room_map = load("res://gen_room_map.gd").new()
#	room_map.inverse_scale_factor = 64
#	room_map.map_file = "res://rooms/min/basic-1-n.map"
#	add_child(room_map)
#	room_map.owner = get_tree().edited_scene_root
#	room_map.verify_and_build()
#	yield(room_map, "build_complete")
#	room_map.apply_transform(RoomTransform.ROTATE_90)
	#room_map.apply_transform(RoomTransform.MIRROR_Z)

class GenRoom:
	var exits: int = RoomExit.NONE
	var use_prescribed_room := false
	var prescribed_filename := ""
	var prescribed_transform: int = RoomTransform.NONE


func generate(sim_generation := false) -> void:
	simming_generation = sim_generation
	
	initialize_maze_gen()
	
	add_feature_rooms()
	
	maze_expansion()
	maze_open_loops()
	
	populate_world()


func add_feature_rooms():
	var num_feature_rooms = feature_room_defs.size()
	
	for feature_room_def in feature_room_defs:
		if not rand_range(0, feature_room_def.chance):
			assert(not feature_room_def.required)
			continue
	
		assert(not feature_room_def.room_defs.empty())
		print(feature_room_def.room_defs.size())
		var room_def_index: int = randi() % feature_room_def.room_defs.size()
		var room: RoomDef = room_defs[room_def_index]
		var room_exits: int = room.exits
		
		var fitting_rooms := Array()
		if find_fitting_rooms(room_exits, feature_room_def, fitting_rooms):
			var fitting_room = fitting_rooms[randi() % fitting_rooms.size()]
			insert_and_lock_room(room, fitting_room, feature_room_def)
		else:
			assert(not feature_room_def.required)

class ExitConfig:
	pass


func compute_exit_transforms() -> void:
	var num_exit_transforms := max_exits * max_transforms
	exit_transforms.resize(num_exit_transforms)
	
	for exit_transform_index in range(num_exit_transforms):
		var exits: int = exit_transform_index % max_exits
		var room_transform: int = exit_transform_index / max_exits
		exit_transforms[exit_transform_index] = get_transformed_exits(exits, room_transform)


func get_precomputed_transformed_exits(exits: int, room_transform: int) -> int:
	return exit_transforms[exits + room_transform * max_exits]


func get_transformed_exits(exits: int, room_transform: int) -> int:
	var ret_val: int = exits & (RoomExit.UP | RoomExit.DOWN)
	
	if room_transform & RoomTransform.MIRROR_X:
		if exits & RoomExit.EAST:
			ret_val |= RoomExit.WEST
		if exits & RoomExit.WEST:
			ret_val |= RoomExit.EAST
	else:
		ret_val |= exits & (RoomExit.EAST | RoomExit.WEST)
	
	if room_transform & RoomTransform.MIRROR_Y:
		if exits & RoomExit.NORTH:
			ret_val |= RoomExit.SOUTH
		if exits & RoomExit.SOUTH:
			ret_val |= RoomExit.NORTH
	else:
		ret_val |= exits & (RoomExit.NORTH | RoomExit.SOUTH)
	
	if room_transform & RoomTransform.ROTATE_90:
		var temp := ret_val
		ret_val &= (RoomExit.UP | RoomExit.DOWN)
		
		if temp & RoomExit.EAST:
			ret_val |= RoomExit.NORTH
		if temp & RoomExit.WEST:
			ret_val |= RoomExit.SOUTH
		if temp & RoomExit.NORTH:
			ret_val |= RoomExit.WEST
		if temp & RoomExit.SOUTH:
			ret_val |= RoomExit.EAST
	
	return ret_val


# Try fitting ExitConfig into graph, taking into account world boundaries and adjacent closed/locked nodes.
# (In other words, every neihbor via an exit must be a valid location and either unopen or open.)
# This is only intended to be used when seeding the graph with feature rooms;
# The room specified by room_index is already validated to be unopen.
func fits(exit_config: int, room_transform: int, room_index: int, allow_unavailable: bool) -> bool:
	var room_x
	var room_y
	var room_z
	
	var transformed_exits: int = get_precomputed_transformed_exits(exit_config, room_transform)
	
	var neighbors := NeighborIndices.new()
	get_neighbor_indices(room_index, neighbors)
	
	var high_x = map_size_x - 1
	var high_y = map_size_y - 1
	var high_z = map_size_z - 1
	
	# Bound conditons: our exits must have somewhere to go
	if room_x == 0 and (transformed_exits & RoomExit.WEST): return false
	if room_x == high_x and (transformed_exits & RoomExit.EAST): return false
	if room_y == 0 and (transformed_exits & RoomExit.SOUTH): return false
	if room_y == high_y and (transformed_exits & RoomExit.NORTH): return false
	if room_z == 0 and (transformed_exits & RoomExit.DOWN): return false
	if room_z == high_z and (transformed_exits & RoomExit.UP): return false
	
	# Outgoing neighbor conditions: we can only connect to unopen or open nodes, never closed or locked
	# (This prevents feature rooms being placed adjacent to each other and forming a closed loop.)
	if allow_unavailable:
		pass # Don't check outgoing neighbors.
	else:
		if (room_x > 0 and (transformed_exits & RoomExit.WEST)) and not is_available_node(neighbors.west_index): return false
		if (room_x < high_x and (transformed_exits & RoomExit.EAST)) and not is_available_node(neighbors.east_index): return false
		if (room_y > 0 and (transformed_exits & RoomExit.SOUTH)) and not is_available_node(neighbors.south_index): return false
		if (room_y < high_y and (transformed_exits & RoomExit.NORTH)) and not is_available_node(neighbors.west_index): return false
		if (room_z > 0 and (transformed_exits & RoomExit.DOWN)) and not is_available_node(neighbors.west_index): return false
		if (room_z < high_z and (transformed_exits & RoomExit.UP)) and not is_available_node(neighbors.west_index): return false
	
	# Incoming neighbor conditions: neighbors that have already been seeded must fit with us.
	if (room_x > 0 and (generated_rooms[neighbors.west_index].exits & RoomExit.EAST)) and (0 == (transformed_exits & RoomExit.WEST)): return false
	if (room_x < high_x and (generated_rooms[neighbors.east_index].exits & RoomExit.WEST)) and (0 == (transformed_exits & RoomExit.EAST)): return false
	if (room_y > 0 and (generated_rooms[neighbors.south_index].exits & RoomExit.NORTH)) and (0 == (transformed_exits & RoomExit.SOUTH)): return false
	if (room_y < high_y and (generated_rooms[neighbors.north_index].exits & RoomExit.SOUTH)) and (0 == (transformed_exits & RoomExit.NORTH)): return false
	if (room_z > 0 and (generated_rooms[neighbors.down_index].exits & RoomExit.UP)) and (0 == (transformed_exits & RoomExit.DOWN)): return false
	if (room_z < high_z and (generated_rooms[neighbors.up_index].exits & RoomExit.DOWN)) and (0 == (transformed_exits & RoomExit.UP)): return false
	
	# All our exits lead to valid spaces, and all neighboring exits lead validly to this point.
	return true


# Doesn't account for opening loops into closed nodes.
func is_available_node(room_index: int) -> bool:
	return is_unopen_node(room_index) or is_open_node(room_index)


func is_unopen_node(room_index: int) -> bool:
	return unopen_room_set.has(room_index)


func is_open_node(room_index: int) -> bool:
	return open_room_set.has(room_index)


func is_closed_node(room_index: int) -> bool:
	return closed_room_set.has(room_index)


func is_locked_node(room_index: int) -> bool:
	return locked_room_set.has(room_index)


func insert_and_lock_room(room_def: RoomDef, fitting_room: FittingRoom, feature_room_def: FeatureRoomDef) -> void:
	var gen_room: GenRoom = generated_rooms[fitting_room.room_index]
	var transformed_exits: int = get_precomputed_transformed_exits(room_def.exits, fitting_room.room_transform)
	
	gen_room.use_prescribed_room = true
	gen_room.exits = transformed_exits
	gen_room.prescribed_filename = room_def.file_name
	gen_room.prescribed_transform = fitting_room.room_transform
	
	if OS.is_debug_build():
		if not simming_generation:
			print("Inserted feature room %s" % room_def.file_name)
			
		assert(unopen_room_set.has(fitting_room.room_index))
		assert(not locked_room_set.has(fitting_room.room_index))
	
	unopen_room_set.erase(fitting_room.room_index)
	locked_room_set[fitting_room.room_index] = true
	
	var neighbors := NeighborIndices.new()
	get_neighbor_indices(fitting_room.room_index, neighbors)
	
	try_expand_maze(transformed_exits, fitting_room.room_index, neighbors, feature_room_def.open_neighbors)


# Tells us where and how we can fit a room
class FittingRoom: # lol
	var room_index: int
	var room_transform: int


func find_open_loop_opportunities(out_opportunities: Array) -> void:
	var high_x = map_size_x - 1
	var high_y = map_size_y - 1
	var high_z = map_size_z - 1
	
	for z in range(high_z + 1):
		for y in range(1, high_y + 1): # We're looking for west and south exits, so we can skip the south face.
			for x in range(1, high_x + 1): # We're looking for west and south exits, so we can skip the west face.
				var room_index = get_room_index(x, y, z)
				
				#assert(is_closed_node(room_index) or is_locked_node(room_index))
				
				# Everything should be closed or locked by now. We skip locked rooms.
				if is_closed_node(room_index):
					var neighbors := NeighborIndices.new()
					get_neighbor_indices(room_index, neighbors)
					
					assert(is_closed_node(neighbors.west_index) or is_locked_node(neighbors.west_index))
					assert(is_closed_node(neighbors.south_index) or is_locked_node(neighbors.south_index))
					
					var room_exits: int = generated_rooms[room_index].exits
					var can_open_west: bool = (room_exits & RoomExit.WEST) == 0
					var can_open_south: bool = (room_exits & RoomExit.SOUTH) == 0
					
					if can_open_west and is_closed_node(neighbors.west_index):
						var op := OpenLoopOpportunity.new()
						out_opportunities.push_back(op)
						op.room_index = room_index
						op.exit = RoomExit.WEST
						op.neighbors = neighbors
					
					if can_open_south and is_closed_node(neighbors.south_index):
						var op := OpenLoopOpportunity.new()
						out_opportunities.push_back(op)
						op.room_index = room_index
						op.exit = RoomExit.SOUTH
						op.neighbors = neighbors


func maze_open_loops():
	var opportunities := Array()
	find_open_loop_opportunities(opportunities)
	
	var num_opportunities_to_open := int((expansion_open_loops_ratio * opportunities.size()) + 0.5)
	
	for op_count in range(num_opportunities_to_open):
		var op_index: int = randi() % opportunities.size()
		var op: OpenLoopOpportunity = opportunities[op_index]
		
		if op.exit & RoomExit.WEST:
			add_exit(generated_rooms[op.room_index], RoomExit.WEST)
			add_exit(generated_rooms[op.neighbors.west_index], RoomExit.EAST)
		
		if op.exit & RoomExit.SOUTH:
			add_exit(generated_rooms[op.room_index], RoomExit.SOUTH)
			add_exit(generated_rooms[op.neighbors.south_index], RoomExit.NORTH)
		
		opportunities.remove(op_index)
	
	if debug:
		print("Opened %d loops." % num_opportunities_to_open)
	
	print_maze()


func maze_expansion():
	# Small arrays for random direction selection.
	var horizontal_exits := Array()
	var vertical_exits := Array()
	
	horizontal_exits.resize(4)
	vertical_exits.resize(2)
	
	var high_x = map_size_x - 1
	var high_y = map_size_y - 1
	var high_z = map_size_z - 1
	
	# Prim's algorithm, modified a la Crest to bias toward horizontal passages
	while not open_room_set.empty():
		assert(open_room_stack.size() == open_room_set.size())
		
		# Modifying Prim's algorithm: expanding from the last expanded room produces more regular floors for me. So do that some portion of the time.
		var follow_last_node: bool = expansion_follow_last_node_ratio >= 1.0 or randf() < expansion_follow_last_node_ratio
		var closed_room_index_index: int = open_room_stack.size() - 1 if follow_last_node else randi() % open_room_stack.size()
		var closed_room_index = open_room_stack[closed_room_index_index]
		
		var coords = get_room_coords(closed_room_index)
		var closed_x := int(coords.x)
		var closed_y := int(coords.y)
		var closed_z := int(coords.z)
		
		var neighbors := NeighborIndices.new()
		get_neighbor_indices(closed_room_index, neighbors)
		
		horizontal_exits.clear()
		vertical_exits.clear()
		
		# Find all the directions we can expand in.
		# We can expand to any unopened node.
		if closed_x > 0 and unopen_room_set.has(neighbors.west_index): horizontal_exits.push_back(RoomExit.WEST)
		if closed_x < high_x and unopen_room_set.has(neighbors.east_index): horizontal_exits.push_back(RoomExit.EAST)
		if closed_y > 0 and unopen_room_set.has(neighbors.south_index): horizontal_exits.push_back(RoomExit.SOUTH)
		if closed_y < high_y and unopen_room_set.has(neighbors.north_index): horizontal_exits.push_back(RoomExit.NORTH)
		if closed_z > 0 and unopen_room_set.has(neighbors.down_index): horizontal_exits.push_back(RoomExit.DOWN)
		if closed_z < high_z and unopen_room_set.has(neighbors.up_index): horizontal_exits.push_back(RoomExit.UP)
		
		# If we can't expand anywhere, this node is closed
		if horizontal_exits.empty() and vertical_exits.empty():
			open_room_stack.remove(closed_room_index_index)
			open_room_set.erase(closed_room_index)
			closed_room_set.erase(closed_room_index)
			continue
		
		# Select the direction we're going to expand
		var expand_horizontal := false
		var expand_direction: int = RoomExit.NONE
		if horizontal_exits.size() and vertical_exits.size():
			# Bias towards levels with less vertical expansion
			expand_horizontal = expansion_horizontal_ratio >= 1.0 or randf() < expansion_horizontal_ratio
		else:
			expand_horizontal = horizontal_exits.size() > 0
		expand_direction = horizontal_exits[randi() % horizontal_exits.size()] if expand_horizontal else vertical_exits[randi() % vertical_exits.size()]
		
		try_expand_maze(expand_direction, closed_room_index, neighbors, true)


func try_expand_maze(exits: int, open_room_index: int, neighbors: NeighborIndices, open_room: bool) -> void:
	if exits & RoomExit.NORTH:
		expand_maze(open_room_index, neighbors.north_index, RoomExit.NORTH, RoomExit.SOUTH, open_room)
	if exits & RoomExit.SOUTH: 
		expand_maze(open_room_index, neighbors.south_index, RoomExit.SOUTH, RoomExit.NORTH, open_room)
	if exits & RoomExit.EAST:
		expand_maze(open_room_index, neighbors.east_index, RoomExit.EAST, RoomExit.WEST, open_room)
	if exits & RoomExit.WEST:
		expand_maze(open_room_index, neighbors.west_index, RoomExit.WEST, RoomExit.EAST, open_room)
	if exits & RoomExit.UP:
		expand_maze(open_room_index, neighbors.up_index, RoomExit.UP, RoomExit.DOWN, open_room)
	if exits & RoomExit.DOWN:
		expand_maze(open_room_index, neighbors.down_index, RoomExit.DOWN, RoomExit.UP, open_room)


func expand_maze(open_room_index: int, unopen_room_index: int, direction: int, opposite_direction: int, open_room: bool) -> void:
	add_exit(generated_rooms[open_room_index], direction)
	add_exit(generated_rooms[unopen_room_index], opposite_direction)
	
	if not open_room:
		return
	
	if is_open_node(unopen_room_index) or is_closed_node(unopen_room_index) or is_locked_node(unopen_room_index):
		# We can expand into already opened rooms when seeding the maze with feature rooms.
		# In that case, we need to make sure we don't re-add the room to the stack!
		pass
	else:
		if OS.is_debug_build():
			assert(unopen_room_set.has(unopen_room_index))
			assert(not open_room_set.has(unopen_room_index))
		
		unopen_room_set.erase(unopen_room_index)
		open_room_stack.push_back(unopen_room_index)
		open_room_set[unopen_room_index] = true


func populate_world():
	for room_index in range(num_rooms):
		var gen_room: GenRoom = generated_rooms[room_index]
		
		var room_filename: String
		var room_transform: int
		get_room_filename_and_transform(gen_room, room_filename, room_transform, null)


func get_neighbor_indices(room_index: int, neighbors: NeighborIndices) -> void:
	neighbors.north_index = room_index + map_size_x
	neighbors.south_index = room_index - map_size_x
	neighbors.east_index = room_index + 1
	neighbors.west_index = room_index - 1
	neighbors.up_index = room_index + map_size_x * map_size_y
	neighbors.down_index = room_index - map_size_x * map_size_y


class NeighborIndices:
	var north_index: int
	var south_index: int
	var east_index: int
	var west_index: int
	var up_index: int
	var down_index: int


func _ready2():
	num_rooms = map_size_x * map_size_y * map_size_z


func initialize(world_gen_def: WorldGenDef) -> void:
	num_rooms = map_size_x * map_size_y * map_size_z
	
	compute_exit_transforms()
	
	for feature_room_def in world_gen_def.feature_room_defs:
		initialize_feature_room(feature_room_def)
	
	initialize_room_defs(null, world_gen_def.room_defs.size(), room_map, world_gen_def)
	
	for theme_index in range(world_gen_def.themes.size()):
		var theme = "TODO"
		themes.push_back(theme)
	
	theme_bias = world_gen_def.theme_bias
	expansion_horizontal_ratio = world_gen_def.horizontal_ratio
	expansion_follow_last_node_ratio = world_gen_def.follow_last_node_ratio
	expansion_open_loops_ratio = world_gen_def.open_loops_ratio
	
	# Any resolve groups not listed default to spawning 100% of entities.
	# TODO ResoleGroups!
	
	
	


func initialize_feature_room(feature_room_def: FeatureRoomDef) -> void:
	assert(feature_room_def)
	
	feature_room_def = feature_room_def.duplicate()
	
	feature_room_defs.push_back(feature_room_def)
	
	if feature_room_def.slice.x < 0:
		feature_room_def.slice.x = map_size_x + feature_room_def.slice.x
	
	if feature_room_def.slice.y < 0:
		feature_room_def.slice.y = map_size_y + feature_room_def.slice.y
	
	var slice_min_x := feature_room_def.slice_min.x
	var slice_min_y := feature_room_def.slice_min.y
	var slice_min_z := feature_room_def.slice_min.z
	
	var slice_max_x := feature_room_def.slice_max.x
	var slice_max_y := feature_room_def.slice_max.y
	var slice_max_z := feature_room_def.slice_max.z
	
	feature_room_def.slice_min_index = get_room_index(slice_min_x, slice_min_y, slice_min_z)
	feature_room_def.slice_max_index = get_room_index(slice_max_x, slice_max_y, slice_max_z)
	
	var room_defs := Array()
	initialize_room_defs(room_defs, feature_room_def.room_defs.size(), null, feature_room_def)
	feature_room_def.room_defs = room_defs


# p_room_defs is an out array of indices to the main room_defs array.
func initialize_room_defs(p_room_defs, num_room_defs: int, room_map, definition) -> void:
	for room_def_index in range(num_room_defs):
		var room_def := RoomDef.new()
		room_defs.push_back(room_def)
		var room_index = room_defs.size() - 1
		
		if p_room_defs is Array:
			p_room_defs.push_back(room_index)
		
		room_def.file_name = definition.room_defs[room_def_index]
		room_def.theme = get_theme_from_filename(room_def.file_name)
		
		room_def.allow_transforms = true
		
		if room_def.prescribed_exits:
			for exit_index in range(room_def.num_exits):
				var exit_name = "TODO"
				#add_exit(room_def, get_exit(exit_name))
		else:
			# For the common case, simplify the config file by ignoring subroom fields
			get_exits_from_filename(room_def.file_name, room_def)


func initialize_maze_gen():
	generated_rooms.clear()
	generated_rooms.resize(num_rooms)
	for i in range(num_rooms):
		generated_rooms[i] = GenRoom.new()
	
	unopen_room_set.clear()
	open_room_set.clear()
	closed_room_set.clear()
	locked_room_set.clear()
	
	# Populate the graph with all rooms.
	for room_index in range(num_rooms):
		unopen_room_set[room_index] = Room.new()


func get_room_filename_and_transform(gen_room: GenRoom, _a, _b, _c):
	# TODO: Other stuff.
	
	lookup_random_theme_room(gen_room)


func lookup_random_theme_room(_a):
	pass


class Room:
	pass


func get_neighbors(room: Vector3) -> Array:
	var neighbors := []
	
	if room.x > 0:
		neighbors.append(Vector3(room.x - 1, room.y, room.z))
	if room.x < width:
		neighbors.append(Vector3(room.x + 1, room.y, room.z))
	if room.y > 0:
		neighbors.append(Vector3(room.x, room.y - 1, room.z))
	if room.y < height:
		neighbors.append(Vector3(room.x, room.y + 1, room.z))
	if room.z > 0:
		neighbors.append(Vector3(room.x, room.y, room.z - 1))
	if room.z < length:
		neighbors.append(Vector3(room.x, room.y, room.z + 1))
	
	return neighbors


func get_direction(room_a: Vector3, room_b: Vector3):
	var direction = room_a - room_b
	
	match direction:
		Vector3(0, 0, -1):
			return Direction.NORTH
		Vector3(0, -1, 0):
			return Direction.UP
		Vector3(-1, 0, 0):
			return Direction.EAST
		Vector3(0, 0, 1):
			return Direction.SOUTH
		Vector3(0, 1, 0):
			return Direction.DOWN
		Vector3(1, 0, 0):
			return Direction.WEST


func get_room_dictionary():
	var room_dictionary = {}
	var dir_map = {}
	
	dir_map[Direction.NORTH] = "n"
	dir_map[Direction.EAST] = "e"
	dir_map[Direction.SOUTH] = "s"
	dir_map[Direction.WEST] = "w"
	dir_map[Direction.UP] = "u"
	dir_map[Direction.DOWN] = "d"
	
	var regex := RegEx.new()
	regex.compile("(?<directions>[nsewudx]{1,6}).map$")
	
	var dir = Directory.new()
	if dir.open("res://rooms/min") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var matches = regex.search_all(file_name)
				for m in matches:
					var dir_string = m.get_string(1)
					var dirs = 0
					for i in range(dir_string.length()):
						match dir_string[i]:
							"n":
								dirs |= Direction.NORTH
							"e":
								dirs |= Direction.EAST
							"s":
								dirs |= Direction.SOUTH
							"w":
								dirs |= Direction.WEST
							"u":
								dirs |= Direction.UP
							"d":
								dirs |= Direction.DOWN
					room_dictionary[dirs] = {file = file_name, room_transform = RoomTransform.NONE}
			file_name = dir.get_next()
	
	for room in room_dictionary.keys():
		for room_transform in range(pow(2, RoomTransform.size())):
			var transformed_exit = get_transformed_exits(room, room_transform)
			if not room_dictionary.has(transformed_exit):
				room_dictionary[transformed_exit] = {file = room_dictionary[room].file, room_transform = room_transform}
	
	return room_dictionary


func add_exit(room_def, new_exit: int) -> void:
	room_def.exits |= new_exit


# This function is not very robust.
# It strips the leading folders and grabs whatever precedes the first dash.
func get_theme_from_filename(room_filename: String) -> String:
	return "TODO"


func get_exits_from_filename(room_filename: String, room_def: RoomDef) -> void:
	var regex := RegEx.new()
	regex.compile("(?<exit_chars>[nsewudx]{1,6}).map$")
	
	var matches = regex.search_all(room_filename)
	for m in matches:
		var exit_chars = m.get_string(1)
		for i in range(exit_chars.length()):
			add_exit(room_def, get_exit(exit_chars[i]))


func get_exit(exit_char: String) -> int:
	match exit_char:
		"n":
			return RoomExit.NORTH
		"e":
			return RoomExit.EAST
		"s":
			return RoomExit.SOUTH
		"w":
			return RoomExit.WEST
		"u":
			return RoomExit.UP
		"d":
			return RoomExit.DOWN
		"x":
			return RoomExit.NONE
		_:
			push_warning("Unrecognized exit_char %s, returning RoomExit.NONE" % exit_char)
			return RoomExit.NONE


func get_room_index(room_x: int, room_y: int, room_z: int) -> int:
	return room_x + (room_y * map_size_x) + (room_z * map_size_x * map_size_y)


func get_room_coords(room_index: int) -> Vector3:
	var coords := Vector3()
	
	coords.x = room_index % map_size_x
	coords.y = (room_index / map_size_x) % map_size_y
	coords.z = ((room_index / map_size_x) / map_size_y) % map_size_z
	
	return coords


func find_fitting_rooms(exit_config: int, feature_room_def: FeatureRoomDef, out_fitting_rooms: Array) -> bool:
	var allow_transforms = feature_room_def.allow_transforms
	var allow_unavailable = feature_room_def.allow_unavailable
	var ignore_fit = feature_room_def.ignore_fit
	var slice_min_room_index = feature_room_def.slice_min_index
	var slice_max_room_index = feature_room_def.slice_max_index
	
	var min_room: Vector3 = get_room_coords(slice_min_room_index)
	
	var max_room: Vector3 = get_room_coords(slice_max_room_index)
	
	var num_transforms := max_transforms if allow_transforms else 1
	
	for z in range(min_room.z, max_room.z + 1):
		for y in range(min_room.y, max_room.y + 1):
			for x in range(min_room.x, max_room.x + 1):
				var room_index: int = get_room_index(x, y, z)
				if ignore_fit or is_unopen_node(room_index):
					for room_transform in RoomTransform.values():
						if ignore_fit or fits(exit_config, room_transform, room_index, allow_unavailable):
							var fitting_room := FittingRoom.new()
							fitting_room.room_index = room_index
							fitting_room.room_transform = room_transform
							out_fitting_rooms.push_back(fitting_room)
	
	return not out_fitting_rooms.empty()


func print_maze():
	if not debug or simming_generation:
		return
	
	for z in range(map_size_z - 1, -1, -1): # Print top to bottom
		print("Floor %d" % z)
		for y in range(map_size_y - 1, -1, -1): # Print north to south
			var row := PoolStringArray()
			for x in range(map_size_x): # Print west to east
				var room_index = get_room_index(x, y, z)
				var exits = generated_rooms[room_index].exits
				row.append("[%2x]" % exits)
			print(row.join(""))
		print("")
