extends Node
class_name Inotifiera


signal file_created(path)
signal file_modified(path)
signal file_deleted(path)

# Reference: http://man7.org/linux/man-pages/man1/inotifywait.1.html
const EVENT_ACCESS = "ACCESS"
const EVENT_MODIFY = "MODIFY"
const EVENT_ATTRIB = "ATTRIB"
const EVENT_CLOSE_WRITE = "CLOSE_WRITE"
const EVENT_CLOSE_NOWRITE = "CLOSE_NOWRITE"
const EVENT_CLOSE = "CLOSE"
const EVENT_OPEN = "OPEN"
const EVENT_MOVED_TO = "MOVED_TO"
const EVENT_MOVED_FROM = "MOVED_FROM"
const EVENT_MOVE = "MOVE"
const EVENT_MOVE_SELF = "MOVE_SELF"
const EVENT_CREATE = "CREATE"
const EVENT_DELETE = "DELETE"
const EVENT_DELETE_SELF = "DELETE_SELF"
const UNMOUNT = "UNMOUNT"

var socat_pid = -1
var stream_peer: StreamPeer = StreamPeerTCP.new()
var regex: RegEx = RegEx.new()
var test_file
var to_delete_name = "TestFile"

var _handlers: Dictionary = {}


func _ready():
	regex.compile("(?<path>[^\\s]*)\\s*(?<action>[^\\s]*)\\s*(?<file>[^\\s]*)")
#	print("Initializing socat")
#	socat_pid = OS.execute("socat",
#			["-d", "-d", "tcp-l:1744,bind=127.0.0.1,reuseaddr,fork",
#			'exec:"$(which\\ inotifywait)\\ -q\\ -m\\ /home/leroy/tmp/test/",pty,setsid,stderr,login,ctty']
#			, false)
#	print("socat running, pid: ", socat_pid)
	# Running socat manually for now.
	
	# Save TestFile so we can duplicate it.
	test_file = get_parent().find_node("index.html").duplicate()
	
	var err = stream_peer.connect_to_host("127.0.0.1", 1746)
	if err != OK:
		print("Couldn't connect stream peer!")
	
	print("Is connected to host? ", stream_peer.is_connected_to_host())


func parse(data) -> void:
	var lines = data.get_string_from_ascii().split("\n")
	
	for line in lines:
		var result = regex.search(line)
		if result:
			var path = result.get_string("path")
			var actions = result.get_string("action").split(",")
			var file = result.get_string("file")
			if not actions.empty() and path:
				for action in actions:
					var id = ({"path": path, "action": action, "file": file if file else ""}).hash()
					for handler in _handlers.get(id, []):
						print("target: ", handler["target"])
						print("method: ", handler["method"])

func write(data: String) -> void:
	stream_peer.put_data(data.to_ascii())


func _process(delta):
	if stream_peer.is_connected_to_host():
		var res = stream_peer.get_data(stream_peer.get_available_bytes())
		var error = res[0]
		var data = res[1]
		if error != OK:
			print("Error getting data")
		elif not data.empty():
			parse(data)


# @param identifier a unique identifier for an event. Should be a dictionary
#   with keys "path", "event", "file". Where "path" is the path of the
#   monitored directory, "event" is a Inotifier.EVENT and "file" is a filename.
func add_event_handler(identifier: Dictionary, target: Object, method: String) -> void:
	var id = identifier.hash()
	var handler = {"target": target, "method": method}
	
	if _handlers.has(id):
		_handlers[id].append(handler)
	else:
		_handlers[id] = [handler]
