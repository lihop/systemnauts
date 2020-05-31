extends Spatial


enum DoorStates {
	OPEN
	CLOSED
}

signal access_denied()
signal access_granted()

var state = DoorStates.CLOSED

# Absolute paths to the directories that this door connects. One directory is
# the parent, the other is the child. For example, if we were making a door to
# /home/player, the paths would be: path_parent = /home, path_child = /home/player.
export var path_parent: String
export var path_child: String

# If automatic is enabled doors will automatically open when authorised bodies
# are in proximity.
export var automatic: bool = true

# Arrays for tracking bodies in proximity of the door on either the parent or
# child side respectively.
var _parent_proximity: Array = []
var _child_proximity: Array = []


func _ready():
	connect("access_granted", self, "open")


func open():
	if state == DoorStates.OPEN:
		return
	
	$AudioOpen.play()
	$AnimationPlayer.play("open")
	state = DoorStates.OPEN


func close():
	$AudioClose.play()
	$AnimationPlayer.play_backwards("open")
	state = DoorStates.CLOSED


func _attempt_access(path: String, body):
	if body.is_in_group("player"):
		RemoteOS.execute("test", ["-x", path])
		var exit_code = yield(RemoteOS, "command_completed")
		if exit_code == 0:
			emit_signal("access_granted")
		


func _on_body_entered(body, parent_side):
	if parent_side:
		_parent_proximity.append(body)
	else:
		_child_proximity.append(body)
	
	# If the door is closed and automatic doors are enabled, we should check
	# if there is an authorised user in proximity and open the door automatically.
	if state == DoorStates.CLOSED and automatic:
		for body in _parent_proximity:
			_attempt_access(path_parent, body)
		
		for body in _child_proximity:
			_attempt_access(path_child, body)


func _on_body_exited(body, parent_side):
	if parent_side:
		_parent_proximity.erase(body)
	else:
		_child_proximity.erase(body)
	
	if state == DoorStates.OPEN:
		# The door should only remain open if an authorised body is
		# in proximity.
		for body in _parent_proximity:
			_attempt_access(path_parent, body)
		
		for body in _child_proximity:
			_attempt_access(path_child, body)
		
		# Nobody in proximity has permission to open the door, so we should
		# close it.
		close()
