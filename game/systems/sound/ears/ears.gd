tool
class_name Ears
extends Listener

signal heard_sound(sound)
signal unheard_sound(sound)

export (bool) var listening := true setget set_listening

var sounds := []


func set_listening(value):
	listening = value
	$Area/CollisionShape.disabled = not listening


func hear_sound(sound) -> void:
	sounds.append(sound)
	emit_signal("heard_sound", sound)


func unhear_sound(sound) -> void:
	sounds.erase(sound)
	emit_signal("unheard_sound", sound)
