class_name NetworkNode
extends Node

const PlayerScene = preload("res://entities/player/player.tscn")

var player_info: Dictionary = {}
var info: Dictionary = {}

master func spawn_player():
	var id = multiplayer.get_rpc_sender_id()

	var player = PlayerScene.instance()

	SyncRoot.add_child(player)
	# TODO: Set spawnpoint.
	player.global_transform.origin = Vector3(-9, 2, 9)

	player.name = str(id)
	player.set_network_master(id)
