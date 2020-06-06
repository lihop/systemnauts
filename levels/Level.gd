extends Node
class_name Level
# Base class for single player levels. Run on both client and server.


var SERVER_PORT = 7154
var MAX_PLAYERS = 1

export var fast_close := true
var mouse_mode: String = "CAPTURED"
export(String) var scene

var _is_server: bool


func _ready():
	get_tree().set_pause(true)
	
	_is_server = OS.has_feature("Server")
	
	_connect_listeners()
	_setup_network()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _connect_listeners():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")


func _setup_network():
	var peer = NetworkedMultiplayerENet.new()
	
	if _is_server:
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
	else:
		peer.create_client("192.168.56.109", SERVER_PORT)
	
	get_tree().network_peer = peer


func _player_connected(id):
	var self_peer_id = get_tree().get_network_unique_id()
	
	$Scene.set_network_master(1)
	
	if _is_server:
		$Scene/Player.set_network_master(id)
	else:
		$Scene/Player.set_network_master(self_peer_id)
	
	# Start the gamef
	get_tree().set_pause(false)
	$Scene._start_scene()


func _player_disconnected(id):
	pass


func _input(event):
	if event.is_action_pressed("ui_cancel") and fast_close:
		get_tree().quit() # Quits the game
	
	if event.is_action_pressed("mouse_input") and fast_close:
		match mouse_mode: # Switch statement in GDScript
			"CAPTURED":
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_mode = "VISIBLE"
			"VISIBLE":
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouse_mode = "CAPTURED"
