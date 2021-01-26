tool
class_name AIEars
extends Ears

export (NodePath) var brain_node := NodePath()

onready var brain: AIBrain = get_node_or_null(brain_node)


func hear_sound(sound):
	.hear_sound(sound)
	if sound is SmartSound:
		if brain and brain.known_objects.has(sound.object):
			for property in sound.propagated_properties:
				brain.known_objects[sound.object][property] = sound.object[property]


func unhear_sound(sound):
	.unhear_sound(sound)
	if sound is SmartSound:
		if brain and brain.known_objects.has(sound.object):
			for property in sound.propagated_properties:
				brain.known_objects[sound.object][property] = sound.object[property]


func _get_configuration_warning() -> String:
	if not get_node_or_null(brain_node) is AIBrain:
		return "Not connected to a brain."

	return ""
