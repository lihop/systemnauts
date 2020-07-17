tool
extends Spatial


const HomeDirectory = preload("res://scenes/spaceship/rooms/home/home_directory/HomeDirectory.tscn")

const MAX_SLOTS = 4

export(int) var slots := 0 setget _set_slots
onready var home_docks := [$GridMap/Dock0, $GridMap/Dock1, $GridMap/Dock2, $GridMap/Dock3]

var _home_directories := []


func _ready():
	_home_directories.resize(MAX_SLOTS)


func _set_slots(num_slots: int) -> void:
	slots = num_slots
	_update_home_directories()
	


func _set_users(users: Array) -> void:
	if users.size() > slots:
		push_error("Too many users! Only have enough slots for %d" % slots)
	
	users = users.slice(0, slots)
	
	_update_home_directories()


func _update_home_directories() -> void:
	for i in range(min(_home_directories.size(), MAX_SLOTS)):
		var dir = _home_directories[i]
		
		if dir:
			dir.queue_free()
	
	if not home_docks:
		return
	
	for i in range(min(home_docks.size(), slots)):
		var dir = HomeDirectory.instance()
		var dock = home_docks[i]
		
		dir.transform = dock.transform
		dir.rotation = dock.rotation
		
		_home_directories[i] = dir
		
		add_child(dir)


class HomeDock:
	# Path to the spatial node where the rooms docking point will be attached.
	export(NodePath) var docking_point
