extends Node
class_name HTTPResponse
# Reference: https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages


const StatusText = {
	# These status texts are taken from the Wikipedia article "List of HTTP status codes" [1]
	# which is released under the Creative Commons Attribution-Share-Alike License 3.0.
	# [1]: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
	
	# 2xx Success
	200: "OK",
	201: "Created",
	202: "Accepted",
	
	# 3xx Redirection
	301: "Moved Permanently",
	
	# 4xx Client errors
	404: "Not Found",
	451: "Unavailable For Legal Reasons",
	
	# 5xx Server errors
	500: "Internal Server Error",
}

var _conn: StreamPeerTCP
var status: int
var headers: Dictionary = {}
var body: PoolByteArray = PoolByteArray([])


func ready():
	pass


func send(body = null):
	if typeof(body) == TYPE_STRING:
		body = body.to_utf8()
	elif typeof(body) != TYPE_RAW_ARRAY:
		push_error("body should be a String or PoolByteArray")
	
	var meta = "HTTP/1.1 %d %s\r\n" % [status, StatusText[status]]
	
	for key in headers.keys():
		meta += "%s: %s\r\n" % [key, headers[key]]
	
	meta += "\r\n"
	
	var connections = $"/root/WebServer"._connections
	if not connections.empty():
		_conn = connections.get(connections.keys()[0])
		_conn.put_data(meta.to_utf8() + body)
