tool
class_name Character
extends Node

const ReGoapAgent = preload("res://addons/ReGoap/Godot/ReGoapAgent.cs")
const ReGoapMemory = preload("res://addons/ReGoap/Godot/ReGoapMemory.cs")

enum CharacterType {
	ENEMY,
	NPC,
	PLAYER,
	VIRTUAL,
}

const CHARACTER_TYPE_ENEMY = CharacterType.ENEMY
const CHARACTER_TYPE_NPC = CharacterType.NPC
const CHARACTER_TYPE_PLAYER = CharacterType.PLAYER
const CHARACTER_TYPE_VIRTUAL = CharacterType.VIRTUAL

export var display_name := ""
export (CharacterType) var character_type := CHARACTER_TYPE_PLAYER
export (Resource) var voice

# Use child nodes for the following.
export (NodePath) var spawn_point
