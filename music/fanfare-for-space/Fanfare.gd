extends Node


var looping = true;


func _ready():
	$Head.connect("finished", $Loop, "play")
	$Loop.connect("finished", self, "_check_looping")


func _check_looping():
	if looping:
		$Loop.play()
	else:
		$Tail.play()
	


func play():
	$Head.play()
