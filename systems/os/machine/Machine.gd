extends Node
class_name Machine


signal finished(request_id)

# The public ipv4 address that clients use to connect to this machine.
var public_ipv4: String

var _threads := {}


# Returns an array containg exit code as the first element and output
# to stdout and/or stderr as the second element.
func execute(path: String, arguments: PoolStringArray = PoolStringArray([]),
		user: String = "", read_stderr: bool = true) -> ExecResponse:
	var req = ExecRequest.new(path, arguments, user, read_stderr)
	var res = ExecResponse.new()
	
	var thread := Thread.new()
	_threads[req.id] = thread
	thread.start(self, "_exec_start", [req, res])
	
	# Wait for execution to finish.
	while true:
		if req.id == yield(self, "finished"):
			break
	
	# It is assumed that each element in output is a new line, so we can remove
	# the new line characters from the output strings.
	for i in range(res.output.size()):
		res.output[i] = res.output[i].trim_suffix("\n")
	
	return res


func _exec_start(data: Array):
	var req = data[0]
	var res = data[1]
	
	if req.user.empty():
		res.exit_code = OS.execute(req.path, req.arguments, true, res.output, req.read_stderr)
	else:
		var args = PoolStringArray(["-u", req.user, "--", req.path])
		args.append_array(req.arguments)
		res.exit_code = OS.execute("runuser", args, true, res.output, true)
	
	call_deferred("_exec_finish", req.id)


func _exec_finish(request_id: int):
	var thread: Thread = _threads.get(request_id)
	
	if not thread:
		push_error("no thread found for request %s" % request_id)
	elif thread.is_active():
		var res = thread.wait_to_finish()
	
	_threads.erase(request_id)
	
	emit_signal("finished", request_id)


func _exit_tree():
	for thread in _threads.values():
		if thread.is_active():
			thread.wait_to_finish()


class ExecRequest:
	extends Reference
	
	
	var id := get_instance_id()
	var path: String
	var arguments := PoolStringArray([])
	var user: String
	var read_stderr := true
	
	
	func _init(path: String, arguments: PoolStringArray = PoolStringArray([]),
			user: String = "", read_stderr: bool = true):
		self.path = path
		self.arguments = arguments
		self.user = user
		self.read_stderr = read_stderr


class ExecResponse:
	extends Reference
	
	
	var exit_code := -1
	var output := []
