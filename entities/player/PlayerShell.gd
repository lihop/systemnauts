extends "res://commander.gd"
# Represents the shell of the player.
# Every action the player takes in the world should be executed through this
# shell (with the exception of if they are at an in game terminal).


############ START OS RELATED FUNCTIONS ###############
# These will probably be moved/rewritten in the not so
# distant future.
func cwd():
	run_command("pwd")
	var data = yield(self, "data_received")
	var lines = data.get_string_from_ascii().split("\n")
	if lines.size() > 1:
		return lines[1].strip_edges()
	else:
		return ""
