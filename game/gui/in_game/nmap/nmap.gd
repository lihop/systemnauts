extends Control

const Host := preload("host.tscn")

export (String) var address
export (int) var netmask := 24

var _rng: RandomNumberGenerator
var _min_x: int
var _max_x: int
var _min_y: int
var _max_y: int

onready var screen := $Screen


func _ready():
	var host: NMapHost = Host.instance()
	var host_size: Vector2 = host.get_shape().extents
	var screen_rect: Rect2 = screen.get_rect()

	# Calculate min/max x/y coordinates based on screen size and host size.
	_min_x = screen_rect.position.x + host_size.x
	_max_x = screen_rect.position.x + screen_rect.size.x - host_size.x
	_min_y = screen_rect.position.y + host_size.y
	_max_y = screen_rect.position.y + screen_rect.size.y - host_size.y


func _rand_coord() -> Vector2:
	var x: int = _rng.randi_range(_min_x, _max_x)
	var y: int = _rng.randi_range(_min_y, _max_y)

	return Vector2(x, y)


master func scan():
	print("scanning the thing")

	_rng = RandomNumberGenerator.new()
	_rng.seed = ("%s/%d" % [address, netmask]).hash()

	for i in range(0, 255):
		var host = yield(add_host("0.0.0.0", null), "completed")
		rpc("add_host", "0.0.0.0", host.position)
	print("done")

sync func add_host(ip_address: String, position):
	var host: NMapHost = Host.instance()
	host.ip_address = ip_address
	host.visible = false
	screen.add_child(host)

	if not position:
		while true:
			host.position = _rand_coord()

			# Wait until the physics step of the next frame so we can detect overlapping areas.
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "physics_frame")

			var overlaps: Array = host.get_overlapping_areas()

			if overlaps.empty():
				break
	else:
		host.position = position

	host.visible = true
	return host


func _on_ScanButton_pressed():
	# Test this: scan()
	rpc_id(Server.SERVER_ID, "scan")
