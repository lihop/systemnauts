extends "res://addons/RadMatt.3DFPP/Test_Objects/pickable/Pickable.gd"


var file_name = "index.html"


func _ready():
	#$Commander.run_command("touch /home/leroy/tmp/test/index.html")
	add_to_group("files")


#func interact(relate):
#	$"/root/PlayerShell".run_command("rm /home/leroy/tmp/test/TestFile")

