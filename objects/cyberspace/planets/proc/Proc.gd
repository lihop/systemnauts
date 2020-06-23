extends "res://objects/cyberspace/planets/common/Planet.gd"


var _processes = {}
var _add_queue = []
var _remove_queue = []


func _ready():
	#LinuxServer.connect("process_forked", self, "_on_process_forked")
	#LinuxServer.connect("process_exited", self, "_on_process_exited")
	pass

func _on_process_forked(pid: int) -> void:
	var node = get_node_or_null("Processes/Pid%d" % pid)
	if node:
		node.visible = true


func _on_process_exited(pid: int, exit_code: int) -> void:
	var node = get_node_or_null("Processes/Pid%d" % pid)
	if node:
		node.visible = false


#func _on_process_forked(pid: int) -> void:
##	var pid_scene = load("res://planets/proc/pid/Pid.tscn").instance()
##	_processes[pid] = pid_scene
##	_set_scene_position(pid, pid_scene)
##	add_child(pid_scene)
#	_add_queue.append(pid)
#
#
#func _on_process_exited(pid: int, exit_code: int) -> void:
##	if _processes.has(pid):
##		var pid_scene = _processes[pid]
##		_processes.erase(pid)
##		pid_scene.queue_free()
#	_remove_queue.append(pid)
#
#
#func _process(delta):
#	for pid in _add_queue:
#		var pid_scene = load("res://planets/proc/pid/Pid.tscn").instance()
#		_processes[pid] = pid_scene
#		_set_scene_position(pid, pid_scene)
#		add_child(pid_scene)
#	_add_queue.resize(0)
#
#	for pid in _remove_queue:
#		if _processes.has(pid):
#			var pid_scene = _processes[pid]
#			_processes.erase(pid)
#			pid_scene.queue_free()
#	_remove_queue.resize(0)
#
#
## Returns where the pid scene should be positioned based on pid. We hardcode
## the values for now.
#func _set_scene_position(pid, scene: Spatial) -> void:
#	var faces = 6
#	var slots_per_face = 256
#	var scene_height = 16
#	var planet_offset = slots_per_face / 2 # Half of the planets height.
#	var scene_offset = scene_height / 2 # Half of the scenes height.
#	var offset = planet_offset + scene_offset
#
#	# First move the scene to the appropriate surface. Cube faces are numbered
#	# as follows where face 1 is in the local up position.
#	#
#	#     |---|
#	#     | 1 |
#	# |---|---|---|
#	# | 6 | 5 | 4 |
#	# |---|---|---|
#	#     | 3 |
#	#     |---|
#	#     | 2 |
#	#     |---|
#
#	# Figure out what face the pid should be on based on its number.
#	var face = _get_face(faces, slots_per_face, pid)
#	print("face: ", face)
#
#	var row_offset = ((pid - 1) % scene_height) * scene_height
#
#	match face:
#		1:
#			scene.translation = Vector3(0, offset, row_offset)
#		2:
#			scene.rotation = Vector3(+90, 0, 0)
#			scene.translation = Vector3(0, row_offset, -offset)
#		3:
#			scene.rotation = Vector3(+180, 0, 0)
#			scene.translation = Vector3(0, -offset, -row_offset)
#		4:
#			scene.rotation = Vector3(0, +90, 0)
#			scene.translation = Vector3(offset, 0, -row_offset)
#		5:
#			scene.rotation = Vector3(-90, 0, 0)
#			scene.translation = Vector3(0, -row_offset, offset)
#		6:
#			scene.rotation = Vector3(0, -90, 0)
#			scene.translation = Vector3(-offset, 0, row_offset)
#
#
#func _get_face(faces, slots_per_face, pid) -> int:
#	print("getting the face %s %s %s" % [faces, slots_per_face, pid])
#	for i in range (1, faces + 1):
#		if (i - 1 * slots_per_face) < pid and pid < i * slots_per_face:
#			return i
#
#	return 1
