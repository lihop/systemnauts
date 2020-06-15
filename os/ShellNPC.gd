extends Shell
class_name ShellNPC
# Shell controlled by an NPC. Simulates human actions.


# Typing speed in words per minute.
export(int) var typing_speed = 100
# If true, will make the delay between key preses random.
export(bool) var random_delay = true
# The range above and below `typing_speed` in which to get a random delay
export(int) var random_range = 20

var _typing := false
var _skip_typing := false


# Simulates a human user typing `text` on a keyboard.
func type(text: String) -> void:
	_typing = true
	
	# Get characters per minute (cpm) from typing speed, and calculate the
	# time to delay between each character based on this.
	var cpm = typing_speed * 5
	var delay = 60.0 / cpm
	var delay_lower = 60.0 / ((typing_speed - random_range) * 5)
	var delay_upper = 60.0 / ((typing_speed + random_range) * 5)
	
	
	print(delay, delay_lower, delay_upper)
	
	for i in range(text.length()):
		if _skip_typing:
			.type(text.substr(i))
			_skip_typing = false
			yield(get_tree(), "idle_frame")
			return
		
		var c = text.substr(i, 1)
		
		if random_delay:
			yield(get_tree().create_timer(rand_range(delay_lower, delay_upper)), "timeout")
		else:
			yield(get_tree().create_timer(delay), "timeout")
		
		.type(c)
	
	_typing = false


func skip_typing() -> void:
	if _typing:
		_skip_typing = true
