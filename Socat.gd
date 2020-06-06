extends Node


signal data_received(data)

var exec = "bash"

var _socat_pid

func _ready():
	# Start socat server.
	_socat_pid = OS.execute("socat", ["tcp-l:1747,bind=127.0.0.1,reuseaddr,fork",
			"exec:bash,pty,setsid,stderr,login,ctty"], false)


func _exit_tree():
		# Stop socat server.
	OS.execute("kill", [_socat_pid])
