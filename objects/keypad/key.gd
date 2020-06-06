extends StaticBody


signal key_pressed()

export(String) var key


func _ready():
	pass


func interact(body):
	emit_signal("key_pressed", key)
