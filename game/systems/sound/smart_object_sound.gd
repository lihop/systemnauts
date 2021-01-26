class_name SmartObjectSound
extends Sound

var object: SmartObject
var object_tags := {}


func _init(p_object: SmartObject):
	object = p_object
