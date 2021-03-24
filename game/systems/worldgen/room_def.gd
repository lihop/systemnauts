class_name RoomDef
extends Resource

export (String) var file_name := ""
export (String) var theme := ""
export (bool) var allow_transforms := true
export (bool) var prescribed_exits := false

var exits: int


func _init(
	p_file_name := "", p_theme := "", p_allow_transforms := true, p_prescribed_exits := false
):
	file_name = p_file_name
	theme = p_theme
	allow_transforms = p_allow_transforms
	prescribed_exits = p_prescribed_exits
