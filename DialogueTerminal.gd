extends Control
# This node functions like a Dialogue box, except it looks like a terminal
# and can execute shell commands.


# Typing speed in words per minute.
export(int) var typing_speed = 100
# If true, will make the delay between key preses random.
export(bool) var random_delay = true
# The range above and below `typing_speed` in which to get a random delay
export(int) var random_range = 20
# If specified, terminal will be connected to the given shell.


func _ready():
#	$Shell.connect("data_received", self, "_on_shell_data")
	pass


# Calls $Terminal.write but simulates the typing of `text`.
func type(text: String) -> void:
	# Get characters per minute (cpm) from typing speed, and calculate the
	# time to delay between each character based on this.
	var cpm = typing_speed * 5
	var delay = 60.0 / cpm
	var delay_lower = 60.0 / ((typing_speed - random_range) * 5)
	var delay_upper = 60.0 / ((typing_speed + random_range) * 5)
	
	
	print(delay, delay_lower, delay_upper)
	
	for i in range(text.length()):
		var c = text.ord_at(i)
		
		if random_delay:
			yield(get_tree().create_timer(rand_range(delay_lower, delay_upper)), "timeout")
		else:
			yield(get_tree().create_timer(delay), "timeout")
#		$Shell.send_data(PoolByteArray([c]))


func _on_shell_data(data):
	rpc("_write_to_terminal", data)


remotesync func _write_to_terminal(data):
	$Terminal.write(data)
