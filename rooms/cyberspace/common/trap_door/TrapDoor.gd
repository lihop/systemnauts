extends Spatial


export(Color) var color = Color(0, 1, 1)

var is_open := false


func _ready():
	$LeftHinge/LeftFlap.color = color
	$RightHinge/RightFlap.color = color
	
	$LeftHinge/LeftFlap._ready()
	$RightHinge/RightFlap._ready()


func open():
	$AnimationPlayer.play("open")


func close():
	pass
