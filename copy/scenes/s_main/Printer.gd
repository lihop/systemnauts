extends StaticBody


var printing = false


func _ready():
	$"/root/WebServer".connect("received_data", self, "do_print_next")
	$AnimationPlayer.connect("animation_finished", self, "_handle_print_finished")

func do_print_next(data):
	rpc("print_next", data)


remotesync func print_next(data: PoolByteArray = PoolByteArray([])):
	print("print_next called")
	print(data.get_string_from_utf8())
	printing = true
	$PrintHead.play()
	$AnimationPlayer.play("print")


func _handle_print_finished(animation):
	if animation == "print":
		$PrintHead.stop()
		$Paper.printed = true
		$Bell.play()


func interact(relate):
	if not printing:
		print_next()


func reset():
	printing = false
	$AnimationPlayer.seek(0, true)
