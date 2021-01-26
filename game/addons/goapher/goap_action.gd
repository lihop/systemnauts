tool
extends Node
class_name GOAPActionInstance

export (Resource) var action setget set_action


func set_action(value: Resource) -> void:
	if not value or value is GOAPAction:
		action = value
	else:
		action = GOAPAction.new()


func _ready():
	pass
	#var GoapAction = new GoapAction()


func _run():
	set_process(true)


func _process(delta):
	print("I am running the so-called action")
