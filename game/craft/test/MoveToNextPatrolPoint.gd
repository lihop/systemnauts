extends AIAction

var actor: AIAgent


class Params:
	extends AIParams
	var actor: AIAgent
	var target: Spatial

	func _init(context).(context):
		pass


func _execute(params: Params):
	actor = params.actor
	actor.target = params.target


func _stop():
	actor.target = null
