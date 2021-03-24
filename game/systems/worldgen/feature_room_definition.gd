tool
class_name FeatureRoomDef
extends Resource

export(float, 0.0, 1.0) var chance := 0.5 setget set_chance
export(bool) var open_neighbors := false
export(bool) var allow_transforms := true
export(bool) var allow_unavailable := false
export(bool) var ignore_fit := false
export(Vector3) var slice := Vector3.ZERO
export(Vector3) var slice_min := Vector3.ZERO
export(Vector3) var slice_max := Vector3.ZERO
export(Array, String, FILE, "*.map") var room_defs := Array()

var slice_min_index: int
var slice_max_index: int

var required := false

func set_chance(value: float) -> void:
	chance = value
	required = chance >= 1.0


func set_slice(value: Vector3):
	slice = Vector3(int(value.x), int(value.y), int(value.z))


func set_slice_min(value: Vector3):
	slice_min = Vector3(int(value.x), int(value.y), int(value.z))


func set_slice_max(value: Vector3):
	slice_max = Vector3(int(value.x), int(value.y), int(value.z))


func _init(p_chance := 0.5, p_open_neighbors := false, p_allow_transforms := true, p_allow_unavailable := false, p_ignore_fit := false, p_slice := Vector3.ZERO,
		p_slice_min := Vector3.ZERO, p_slice_max := Vector3.ZERO):
	self.chance = p_chance
	open_neighbors = p_open_neighbors
	ignore_fit = p_ignore_fit
	slice = p_slice
	slice_min = p_slice_min
	slice_max = p_slice_max
