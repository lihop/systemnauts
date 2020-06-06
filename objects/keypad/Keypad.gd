extends Spatial


signal enter_pressed(code)
signal clear_pressed()

const DEFAULT_PERMISSIONS = "d?????????"
const DEFAULT_CODE = "___"

export(String) var directory

var _permissions := DEFAULT_PERMISSIONS
var _code := []


func _ready():
	$LabelPermissions.text = DEFAULT_PERMISSIONS
	$LabelCode.text = DEFAULT_CODE if _code.empty() else "%d%d%d" % _code
	
	_setup_animations()
	
	for key in range(0, 10) + ["fn1", "fn2"]:
		get_node("key-%s/static_collision" % key).connect("key_pressed", self, "_key_pressed")
	
	for key in range(0, 10):
		get_node("key-%s/static_collision" % key).connect("key_pressed", self, "_numeric_key_pressed")
	
	get_node("key-fn1/static_collision").connect("key_pressed", self, "_cancel_pressed")
	get_node("key-fn2/static_collision").connect("key_pressed", self, "_enter_pressed")


func _setup_animations():
	for i in range(0, 10) + ["fn1", "fn2"]:
		var animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		
		animation.length = 0.1
		animation.track_set_path(track_index, "key-%s:translation" % i)
		animation.track_insert_key(track_index, 0, Vector3(0, 0, 0))
		animation.track_insert_key(track_index, 0.05, Vector3(0, 0, -0.007))
		animation.track_insert_key(track_index, 0.1, Vector3(0, 0, 0))
		
		$AnimationPlayer.add_animation("key_press_%s" % i, animation)


func _key_pressed(key):
	$AnimationPlayer.play("key_press_%s" % key)
	# TODO sound effect


func _numeric_key_pressed(number):
	match _code.size():
		3:
			access_denied()
		2, 1, 0:
			_code.append(number)
			continue
		2:
			$LabelCode.text = "%s%s%s" % _code
		1:
			$LabelCode.text = "_%s%s" % _code
		0:
			$LabelCode.text = "__%s" % _code


func _cancel_pressed(_key):
	_code = []
	$LabelCode.text = DEFAULT_CODE


func _enter_pressed(_key):
	_cancel_pressed(null)
	access_granted()


func access_denied():
	$AnimationPlayer.play("blink_red")
	$AccessDeniedAudio.play()


func access_granted():
	var material = $"keypad-indicator".mesh.surface_get_material(0)
	material.emission = Color(0, 1, 0, 1)
	material.emission_energy = 1
	$AccessGrantedAudio.play()


remotesync func _set_permissions_text() -> void:
	$Label3D.text = _permissions
