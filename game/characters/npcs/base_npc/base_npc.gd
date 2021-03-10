class_name NPC
extends BaseCharacter

const DetourCrowdAgentParameters: NativeScript = preload("res://addons/godotdetour/detourcrowdagentparameters.gdns")

const MAX_SPEED = 3.0
const HEIGHT = 1.9

signal arrived_at_target

var _navigation
var _nav_agent
var _target
var _target_range


# Temp: testing movement.
func _unhandled_input(event):
	if event.is_action_pressed("test"):
		var player = get_tree().get_nodes_in_group("players")[0]
		#go_to(player.global_transform.origin)
		rpc_id(get_network_master(), "go_to", player.global_transform.origin)


func init_navigation(navigation: DetourNavigation):
	var params = DetourCrowdAgentParameters.new()

	params.position = global_transform.origin
	params.radius = 0.3
	params.height = HEIGHT
	params.maxAcceleration = 6.0
	params.maxSpeed = MAX_SPEED
	params.filterName = "default"
	params.anticipateTurns = true
	params.optimizeVisibility = true
	params.optimizeTopology = true
	params.avoidObstacles = true
	params.avoidOtherAgents = true
	params.obstacleAvoidance = 1
	params.separationWeight = 1.0

	_nav_agent = navigation.add_agent(params)
	_navigation = navigation


func _physics_process(delta):
	if _nav_agent and _nav_agent.isMoving:
		velocity = _nav_agent.velocity

		translation = _nav_agent.position
		var look_target = translation + _nav_agent.velocity
		if look_target != global_transform.origin:
			look_at(look_target, global_transform.basis.y)

		var distance = _target - _nav_agent.position
		if distance.y <= HEIGHT:
			var horizontal_distance = Vector2(distance.x, distance.z).length()
			if horizontal_distance <= _target_range:
				emit_signal("arrived_at_target")


master func go_to(position, target_range := 0.5):
	_nav_agent.moveTowards(position)
	_target = position
	_target_range = target_range


func _exit_tree():
	_navigation.remove_agent(_nav_agent)


func _on_arrived_at_target():
	if _nav_agent.isMoving:
		_nav_agent.stop()
		velocity = Vector3.ZERO
