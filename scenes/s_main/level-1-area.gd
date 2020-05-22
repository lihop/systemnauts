extends Area


func _ready():
	connect("body_entered", self, "_body_entered")
	connect("body_exited", self, "_body_exited")


func _body_entered(body: Node):
	if body.is_in_group("player"):
		$"/root/PlayerShell".run_command("cd out")
	elif body.is_in_group("files"):
		$"/root/PlayerShell".run_command("mv /home/leroy/tmp/test/%s /home/leroy/tmp/test/out/%s" % [body.file_name, body.file_name])
	


func _body_exited(body: Node):
	if body.is_in_group("player"):
		$"/root/PlayerShell".run_command("cd /home/leroy/tmp/test")
	if body.is_in_group("files"):
		$"/root/PlayerShell".run_command("mv /home/leroy/tmp/test/out/%s /home/leroy/tmp/test/%s" % [body.file_name, body.file_name])
