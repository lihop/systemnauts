class_name NetworkNode
extends Node

const PlayerScene = preload("res://entities/characters/player/player.tscn")

var player_info: Dictionary = {}
var info: Dictionary = {}

master func spawn_player():
	var id = multiplayer.get_rpc_sender_id()

	var player = PlayerScene.instance()

	player.name = str(id)
	player.set_network_master(id)

	SyncRoot.add_child(player)

	player.global_transform.origin = SpawnPoint.get_spawn_point(
		"Player_SpawnPoint_0"
	).global_transform.origin
