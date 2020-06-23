extends WorldEnvironment
# The OperatingSystem is the gravitationally bound system of the Kernel and the
# objects that orbit it.


onready var _player = $Player
onready var _cockpit = $Cockpit

var _current_vehicle: Spatial


func _ready():
	_current_vehicle = _player
	remove_child(_cockpit)


func _process(_delta):
	if Input.is_action_just_pressed("enter_vehicle"):
		match _current_vehicle:
			_player:
				_cockpit.global_transform = _current_vehicle.global_transform
				remove_child(_current_vehicle)
				_current_vehicle = _cockpit
				_current_vehicle.transform.origin.y += 10
				add_child(_current_vehicle)
			_cockpit, _:
				_player.global_transform = _current_vehicle.global_transform
				remove_child(_current_vehicle)
				_current_vehicle = _player
				_current_vehicle.transform.origin.y += 10
				add_child(_current_vehicle)
