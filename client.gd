extends Node


const PlayerShell = preload("res://addons/RadMatt.3DFPP/PlayerShell.gd")

signal connected()
signal authenticated()

var player


func _ready():
	player = preload("res://addons/RadMatt.3DFPP/Player.tscn").instance()
	var Shell = PlayerShell.new()
	Shell.set_name("Shell")
	player.add_child(Shell)
	
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client("nix", 45122)
	get_tree().network_peer = peer
	
	var world = load("res://scenes/s_main/S_Main.tscn").instance()
	world.set_name("world")
	
	var id = get_tree().get_network_unique_id()
	player.set_name(str(id))
	player.set_network_master(id)
	player.get_node("Yaw/Camera").current = true
	world.add_child(player)
	add_child(world)
	
	yield(self, "connected")



remote func player_joined(id):
	if id == get_tree().get_network_unique_id():
		print("I joined Server")
		return
	
	print("Player ", str(id), " joined Server")
	
	var player = preload("res://addons/RadMatt.3DFPP/Player.tscn").instance()
	player.set_name(str(id))
	player.set_network_master(id)
	player.set_process_unhandled_input(false)
	get_child(0).add_child(player)


remote func player_left(id):
	print("Player ", str(id), " left Server")
	
	var player = get_child(0).get_node_or_null(str(id))
	
	if player:
		player.queue_free()


# Function called when the server wants to verify the clients identity.
# The client needs to create a file in /tmp with the same name as `token`
# containing the pid of the client shell.
remote func authenticate(token: String):
	print("Wants me to verify!")
	print(token)
	# $$ is the pid of the shell itself.
	player.shell.run_command("echo $$ > /tmp/%s" % token)
	emit_signal("authenticated")
	print("emitted authenticated!")


remote func authenticated():
	emit_signal("connected")
