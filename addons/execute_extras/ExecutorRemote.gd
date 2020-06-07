extends Node
class_name ExecutorRemote


signal _response_received(response)

var _threads := {}


func _exit_tree():
	for thread in _threads.values():
		thread.wait_to_finish()


# This is the function that should be called on the client
# and will be executed on the server.
func execute(path: String, arguments: PoolStringArray = PoolStringArray([]),
		output: Array = []) -> int:
	var req = ExecRequest.new(path, arguments)
	
	rpc_id(1, "_execute_local", req.as_json())
	
	# TODO: Possibly add a timeout to prevent an inifinite loop here.
	var res = null
	while not res or not res.request_id == req.id:
		res = yield(self, "_response_received")
	
	output.resize(0)
	for el in res.output:
		for line in el.split("\n"):
			output.append(line)
	
	return res.exit_code


# Similar to execute except it returns a value every time a new line is sent
# to stdout or stderr.
func execute_co(path: String, arguments: PoolStringArray = PoolStringArray([]),
		output: Array = []):
	pass


# This function will can be called remotely the execute the function locally
# on the server. Should only ever be called on the server.
remote func _execute_local(request_json: String):
	if not OS.has_feature("Server"):
		push_error("_execute_local can only be called on the server")
	
	var req = ExecRequest.from_json(request_json)
	var res = ExecResponse.new(get_tree().get_rpc_sender_id(), req.id)

	var thread := Thread.new()
	_threads[res.id] = thread
	thread.start(self, "_execute_async", [req, res])


# OS.execute but in a Thread.
func _execute_async(userdata: Array) -> ExecResponse:
	var req = userdata[0]
	var res = userdata[1]
	
	# TODO: Execute as another user if req.user is specified.
	res.exit_code = OS.execute(req.path, req.arguments, true, res.output, true)
	
	call_deferred("_send_execute_response", res.id)
	
	return res


func _send_execute_response(response_id: String):
	var thread: Thread = _threads.get(response_id)
	
	if not thread:
		push_warning("no thread found for response " % response_id)
	else:
		var res = thread.wait_to_finish()
		_threads.erase(response_id)
		
		rpc_id(res.rpc_sender_id, "_execute_response", res.as_json())


# This function is called with the response from the server. It should only
# ever be called on/ the client.
remote func _execute_response(response_json: String):
	if OS.has_feature("Server"):
		push_error("_execute_response can only be called on the client")
	
	var res = ExecResponse.from_json(response_json)
	
	# Check that this response is actually for a request from us.
	assert(res.rpc_sender_id, get_tree().get_network_unique_id())
	
	emit_signal("_response_received", res)


class ExecRequest:
	extends Reference
	
	
	var id := get_instance_id()
	var path: String
	var arguments: PoolStringArray
	var user: String
	
	
	static func from_json(json: String) -> ExecRequest:
		var parsed = parse_json(json)
		
		var request = ExecRequest.new(parsed.path,parsed.arguments, parsed.user)
		request.id = parsed.id
		
		return request
	
	
	func _init(path: String, arguments: PoolStringArray = PoolStringArray([]),
			user: String = ""):
		self.path = path
		self.arguments = arguments
	
	
	func as_json() -> String:
		return to_json({
			"id": id,
			"path": path,
			"arguments": arguments,
			"user": user,
		})


class ExecResponse:
	extends Reference
	
	var id: String setget ,_get_id
	var rpc_sender_id: int
	var request_id: int
	var exit_code: int
	var output := []
	
	
	func _get_id() -> String:
		return "%d/%d" % [self.rpc_sender_id, self.request_id]
	
	
	static func from_json(json: String) -> ExecResponse:
		var parsed = parse_json(json)
		
		var response = ExecResponse.new(parsed.rpc_sender_id, parsed.request_id)
		response.exit_code = parsed.exit_code
		response.output = parsed.output
		
		return response
	
	
	func _init(rpc_sender_id: int, request_id: int):
		self.rpc_sender_id = rpc_sender_id
		self.request_id = request_id
	
	
	func as_json() -> String:
		return to_json({
			"rpc_sender_id": rpc_sender_id,
			"request_id": request_id,
			"exit_code": exit_code,
			"output": output,
		})
