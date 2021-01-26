class_name ConstantConsideration
extends Consideration

export (float, 0, 1) var constant


func _score(params):
	return constant
