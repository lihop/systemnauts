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
		body.shell.run_command("echo hillo >> /home/leroy/lol")


func _on_body_exited(body):
	pass
