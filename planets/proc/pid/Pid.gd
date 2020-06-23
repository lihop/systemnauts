tool
extends Spatial


onready var _high = $pid
onready var _low = $pid/pid_low


func _ready():
	visible = false


func show():
	# Temp disable collision while testing.
	$pid/static_collision/shape0.disabled = true
	
	# Temp hide hq model for now.
	_high.remove_child(_low)
	remove_child(_high)
	add_child(_low)
	
	visible = true
