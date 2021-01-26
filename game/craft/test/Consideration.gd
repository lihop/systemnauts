class_name ActionCooldown
extends BooleanConsideration

enum Type {
	WITHIN,
	AFTER,
}

const COOL_DOWN_WITHIN = Type.WITHIN
const COOL_DOWN_AFTER = Type.AFTER

export (Type) var type
export (float) var seconds
export (Array, NodePath) var actions


func _score(context):
	return true
