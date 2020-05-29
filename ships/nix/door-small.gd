extends Spatial


enum DoorStates {
	OPEN
	CLOSED
}

var state = DoorStates.CLOSED

# Absolute paths to the directories that this door connects. One directory is
# the parent, the other is the child. For example, if we were making a door to
# /home/player, the paths would be: path_parent = /home, path_child = /home/player.
export var path_parent: String
export var path_child: String

# Arrays for tracking bodies in proximity of the door on either the parent or
# child side respectively.
var _parent_proximity: Array = []
var _child_proximity: Array = []


func open():
	$AudioOpen.play()
	$AnimationPlayer.play("open")
	state = DoorStates.OPEN


func close():
	$AudioClose.play()
	$AnimationPlayer.play("close")
	state = DoorStates.CLOSED


func _can_open(path: String, body):
	# TODO: Check if user `body` has permission to enter diretory `path`.
	return true


func _on_body_entered(body, parent_side):
	print("area entered ", body, " ", parent_side)
	if parent_side:
		_parent_proximity.append(body)
	else:
		_child_proximity.append(body)
	
	if state == DoorStates.CLOSED:
		# Check if the door should be opened based on bodies in proximity.
		for body in _parent_proximity:
			if _can_open(path_parent, body):
				open()
				return
		
		for body in _child_proximity:
			if _can_open(path_child, body):
				open()
				return


func _on_body_exited(body, parent_side):
	print("area exited ", body, " ", parent_side)
	if parent_side:
		_parent_proximity.erase(body)
	else:
		_child_proximity.erase(body)
	
	if state == DoorStates.OPEN:
		# Check if door should be closed based on bodies in proximity.
		for body in _parent_proximity:
			if _can_open(path_parent, body):
				return
		
		for body in _child_proximity:
			if _can_open(path_child, body):
				return
		
		# Nobody in proximity has permission to open the door, so we should
		# close it.
		close()
