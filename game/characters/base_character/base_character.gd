class_name BaseCharacter
extends KinematicBody

export (float) var max_speed := 3.0

var velocity := Vector3()


func save():
	var save_dict = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position": global_transform.origin,
	}
	return save_dict
