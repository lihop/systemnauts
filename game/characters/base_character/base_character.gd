class_name BaseCharacter
extends KinematicBody

export (float) var max_speed := 3.0

var velocity := Vector3()


func save():
	var save_dict = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"name": name,
		"global_transform": var2str(global_transform)
	}
	return save_dict
