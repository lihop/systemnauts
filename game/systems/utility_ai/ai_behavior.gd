class_name AIBehavior, "icons/ai_behavior_set.svg"
extends Node

export (bool) var enabled := true

var actions := []


func _ready():
	for child in get_children():
		if child is AIAction:
			actions.append(child)


func add_child(node: Node, legible_unique_name: bool = false):
	if node is AIAction:
		actions.append(node)
	.add_child(node)


func remove_child(node: Node):
	if node is AIAction:
		actions.erase(node)
	.remove_child(node)


func add_options(context: AIDecisionContext):
	if not enabled:
		return

	for child in get_children():
		child.add_options(context)
