tool
extends QodotEntity


func update_properties():
	.update_properties()
	if 'angle' in properties:
		rotation.y = deg2rad(int(properties.angle) - 90)
	else:
		rotation.y = deg2rad(-90)
