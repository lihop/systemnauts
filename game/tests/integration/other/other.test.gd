extends "res://addons/gut/test.gd"


func test_thing():
	var thing = preload("other.tscn")
	var blah = thing.instance()
	watch_signals(blah)
	blah.Emit()
	assert_signal_emitted_with_parameters(blah, "Hah", [])
