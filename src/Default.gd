extends Control

var i:int = 1

func _on_Button_pressed() -> void:
	_button_Pressed_funcs()
	i = i + 1
	
func _button_Pressed_funcs() -> void:
	print("Button Clicked " , i , " time/s.")

