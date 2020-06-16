extends StaticBody


signal key_pressed(key)
signal key_pressed_by(who)

export(String) var key


func _ready():
	pass


func interact(body):
	emit_signal("key_pressed", key)
	emit_signal("key_pressed_by", body)
