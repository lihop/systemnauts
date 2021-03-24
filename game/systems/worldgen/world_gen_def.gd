tool
class_name WorldGenDef
extends Resource

export (float) var follow_last_node_ratio := 0.5
export (float) var horizontal_ratio := 0.75
export (float) var open_loops_ratio := 0.2

export (Array, String) var themes := Array()
export (float) var theme_bias := 3.0

export (Array, Resource) var feature_room_defs := Array()
export (Array, String, FILE, "*.map") var room_defs := Array()

export (String) var start_room_def
