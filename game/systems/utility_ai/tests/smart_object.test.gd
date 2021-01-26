extends "res://addons/gut/test.gd"


class TestMentalRepresentation:
	extends "res://addons/gut/test.gd"

	var smart_object: SmartObject
	var mental_repr: SmartObject

	func before_each():
		smart_object = add_child_autofree(preload("smart_object_test.tscn").instance())
		mental_repr = autofree(smart_object.mental_representation())

	func test_mental_repr_is_inside_tree():
		assert_true(mental_repr.is_inside_tree())

	func test_mental_repr_is_invisible():
		assert_false(mental_repr.visible)

	func test_mental_repr_has_same_initial_state():
		assert_eq(mental_repr.alerting, false)
		assert_eq(mental_repr.cans, 7)

	func test_mental_repr_state_does_not_update_with_original_state():
		smart_object.cans -= 1

		assert_eq(smart_object.cans, 6)
		assert_eq(mental_repr.cans, 7)

	func test_mental_repr_transform_does_not_move_with_original_transform():
		assert_eq(smart_object.global_transform.origin, Vector3.ZERO)
		assert_eq(mental_repr.global_transform.origin, Vector3.ZERO)

		smart_object.global_transform.origin = Vector3(1, 2, 3)

		assert_eq(smart_object.global_transform.origin, Vector3(1, 2, 3))
		assert_eq(mental_repr.global_transform.origin, Vector3.ZERO)

	func test_mental_repr_does_not_move_with_parent_transform():
		var spatial = add_child_autofree(Spatial.new())
		spatial.global_transform.origin = Vector3(9, 9, 9)

		assert_true(mental_repr.is_inside_tree())
		mental_repr.get_parent().remove_child(mental_repr)
		spatial.add_child(mental_repr)

		assert_eq(mental_repr.global_transform.origin, Vector3(9, 9, 9))
		spatial.global_transform.origin = Vector3(1, 2, 3)
		assert_eq(mental_repr.global_transform.origin, Vector3(9, 9, 9))
