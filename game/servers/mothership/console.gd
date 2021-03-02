extends Spatial


func _ready():
	yield(get_tree().create_timer(5), "timeout")
	$Viewport/NMap.scan()
