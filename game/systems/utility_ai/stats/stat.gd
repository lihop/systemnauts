class_name Stat
extends Resource

export (String) var name: String
export (float, 0.0, 1.0) var value: float
export (float, 0.0, 1.0) var setpoint := 1.0
export (Curve) var response_curve: Curve


func _init(p_name := "Stat", p_value := 1.0, p_setpoint := 1.0, p_response_curve := Curve.new()):
	resource_name = p_name
	name = p_name
	value = p_value
	setpoint = p_setpoint
	response_curve = p_response_curve
