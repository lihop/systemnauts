extends Area
class_name DirectoryArea
# Represents the area of a directory. When a user enters the directory area,
# their shell cds into that directory. It can also be used to track file
# locations.


export(String) var path


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.shell.run_command("cd %s" % path)


func _on_body_exited(body):
	# Because the boundary between directory areas is flat and players are
	# 3D a player can be in two directory areas at once. A situation can arise
	# where they have entered (and therefore cded) to the new directory, but
	# have not yet exited the previous directory.
	# If they return fully to previous directory they will still be in the new
	# directory as they do not trigger the body_entered event.
	# Therefore we can check if a body is still in this directory when they
	# exit and, if so, simply cd to the previous directory.
	if body.is_in_group("player"):
		var cwd = yield(body.cwd(), "completed")
		if cwd == path:
			body.shell.run_command("cd -")
