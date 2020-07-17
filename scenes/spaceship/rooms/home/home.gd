extends Spatial


func _ready():
	pass
	# TODO:
	# 1. Register a file watcher with Audit on /etc/passwd for write events.
	# 2. _on_passwd_write event:
	#		1. Run script that uses getpwnam to get a list of home directories.
	#		2. Update scene to match:
	#			1. If more than 4 users, add extra module.
	#			2. For each home directory counting 0..N, attach the home
	#				directory scene for that user and generate contents if
	#				necessary
#	passwd_written_callback.instance = self
#	passwd_written_callback.call_func("_on_passwd_written")
#
	Audit.register_watch("/home/leroy/tmp/test.txt", funcref(self, "_on_passwd_accessed"))


#func _exit_tree():
#	Audit.disconnect_watcher(passwd_watcher)
#
#
func _on_passwd_accessed():
	print("passwd was written to m8!")
	pass
