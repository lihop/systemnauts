extends Node
class_name Process

signal pid_updated(pid)

var pid: int
var uid: int
var gid: int
var groups := PoolIntArray([])
var cwd: String


func get_cwd_async() -> String:
	print("get_cwd for pid: ", pid)
	
	var output = []
	var exit_code = yield(VM.execute("readlink", ["-f", "/proc/%d/cwd" % pid],
			output), "completed")
	
	if exit_code == 0:
		print("got cwd: ", output as Array)
		return output[0]
	else:
		var message = "" if output.empty() else output[0]
		push_error("(Error %d) getting cwd async: %s" % [exit_code, message])
		return ""
