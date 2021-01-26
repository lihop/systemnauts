class_name AIAgent
extends KinematicBody

const DetourCrowdAgent: NativeScript = preload("res://addons/godotdetour/detourcrowdagent.gdns")
const DetourCrowdAgentParameters: NativeScript = preload("res://addons/godotdetour/detourcrowdagentparameters.gdns")

var nav_agent setget set_nav_agent
var nav_filter: Dictionary
var target: Spatial setget set_target

onready var stats: Stats = $Brain/Stats
onready var ears: Ears = get_node_or_null("Ears")
onready var smp := $StateMachinePlayer
onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_target(value):
	if target != value:
		target = value
		if target:
			smp.set_trigger("target_set")
		else:
			smp.set_trigger("target_unset")


func set_nav_agent(value):
	if nav_agent != value:
		nav_agent = value
		nav_agent.connect("arrived_at_target", smp, "set_trigger", ["arrived_at_target"])


func _ready():
	for child in get_children():
		if child is Ears:
			ears = child


func _on_StateMachinePlayer_updated(state, delta):
	match state:
		"GoTo":
			translation = nav_agent.position
			if nav_agent.velocity != Vector3.ZERO:
				look_at(translation + nav_agent.velocity, transform.basis.y)
		_:
			pass


func _on_StateMachinePlayer_transited(from, to):
	match from:
		"GoTo":
			nav_agent.stop()
		_:
			pass

	match to:
		"GoTo":
			nav_agent.moveTowards(target.global_transform.origin)
		"Idle":
			$AnimationPlayer.play("Idle")
		_:
			pass
