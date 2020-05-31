extends Node


const PORT = 45122
const MAX_PLAYERS = 4

signal found_token()

var players = {}

var _socat_pid: int


func _ready():
	# Start socat server.
	_socat_pid = OS.execute("socat", ["tcp-l:1747,bind=127.0.0.1,reuseaddr,fork",
			"exec:bash,pty,setsid,stderr,login,ctty"], false)
	
	var server = NetworkedMultiplayerENet.new()
	server.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(server)
	
	get_tree().connect("network_peer_connected", self, "_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	
	var world = load("res://scenes/s_main/S_Main.tscn").instance()
	world.name = "world"
	add_child(world)


func _exit_tree():
	# Stop socat server.
	OS.execute("kill", [_socat_pid])


func _client_connected(id):
	print("Client ", str(id), " connected to Server")
	
	# Perform client authentication.
	# See: https://github.com/lihop/systemnauts/issues/1
	
	# Generate a random token.
	var uuid = []
	OS.execute("uuidgen", [], true, uuid)
	var token = "systemnauts-%s" % uuid[0].trim_suffix("\n")
	
	print("requesting client verification")
	rpc_id(id, "authenticate", token)
	print("request sent")
	
	# Setup a watcher for the token.
	Inotifier.add_file_event_handler("/tmp", token, self, "_on_found_token", Inotifier.EVENT_CREATE)
	yield(self, "found_token")
	
	# Verify the token
	var file = File.new()
	file.open("/tmp/%s" % token, File.READ)
	var pid = file.get_line()
	file.close()
	
	print("Found pid: ", pid)
	var output = []
	OS.execute("stat", ["-c", "%u", "/tmp/%s" % token], true, output)
	var uid = output[0].trim_suffix("\n")
	
	# Delete the token file.
	OS.execute("rm", ["/tmp/%s" % token], false)
	
	# Get process uid.
	file.open("/proc/%s/loginuid" % pid, File.READ)
	var process_uid = file.get_line()
	
	# Check process uid against token file uid.
	if uid != process_uid:
		print("Wrong uid: ", uid, " != ", process_uid)
		return
	
	print("uid and pid match!")
	
	rpc_id(id, "authenticated")
	
	var new_client = load("res://remote_client.tscn").instance()
	new_client.set_name(str(id))
	new_client.set_network_master(id)
	get_child(0).add_child(new_client)
	
	rpc("player_joined", id)
	
	# Tell the new player about existing players
	for player_id in players.keys():
		rpc_id(id, "player_joined", player_id)
	
	# Add the new player to the players dictionary
	players[id] = {"uid": uid, "pid": pid}


func _client_disconnected(id):
	print("Client ", str(id), " disconnected from Server")
	
	rpc("player_left", id)
	
	var player = get_child(0).get_node_or_null(str(id))
	
	if player:
		player.queue_free()
	
	players.erase(id)


remote func _update_client_position(new_position):
	pass
	# TODO assign new position to server's client representation
	# TODO send new position to all other clients


func _on_found_token():
	print("found the token")
	emit_signal("found_token")
	print("token was found!")
