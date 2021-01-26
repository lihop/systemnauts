class_name AIDecisionContext
extends Reference

var options := []
var params := {}
var known_objects := []
var current_actions := []
var events := AIEventQueue.new()
var bonus := 0.0
var actor


func reset():
	options = []
	params = {}


func duplicate() -> AIDecisionContext:
	var context = get_script().new()
	context.params = params.duplicate()
	context.options = options.duplicate()
	context.params = params.duplicate()
	context.known_objects = known_objects.duplicate()
	context.current_actions = current_actions.duplicate()
	context.actor = actor
	return context
