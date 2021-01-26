class_name PropagatedSound
extends AudioStreamPlayer3D

# Assuming we have a framerate of 60fps and allow up to 250ms between
# updates, then we only need to have update a listener every 15 frames.
const UPDATE_FREQUENCY := 15.0

# Bodies in this layer might effect sound in some way. For example, walls might
# muffle sound.
export (int, LAYERS_3D_PHYSICS) var audio_collision_mask

# The listener that hears that sounds that will be played through the player's
# real-world computer hardware.
var current_listener: Listener = null

# Other listeners that might be interested in this sound at a conceptual level but
# don't actually 'hear' anything. For example, AI agents or sound detection devices.
var listeners := []

var _batch_size := 1  # Number of regular listeners to update at a time.
var _batch_start := 0  # The index of the first item of the next batch.
var _current_collider

onready var _bus_name := str(get_instance_id())


func _set(property, value):
	match property:
		"max_distance":
			$Area/CollisionShape.shape.radius = value / 2.0


func _physics_process(_delta):
	if not playing:
		return

	# Cast a ray to the ears of each listener to determine what materials the
	# sound passes through, allowing us to add effects or adjust the volume.
	var obstruction := {}
	var space_state = get_world().direct_space_state

	# Because the current_listener is responsible for the actual sounds heard by
	# the player, it should be updated every frame in order to be responsive.
	if current_listener:
		obstruction = space_state.intersect_ray(
			self.global_transform.origin,
			current_listener.global_transform.origin,
			[$Area],
			audio_collision_mask
		)

		if obstruction.empty():
			var bus_index = AudioServer.get_bus_index(_bus_name)
			for _i in range(AudioServer.get_bus_effect_count(bus_index)):
				AudioServer.remove_bus_effect(bus_index, 0)
				_current_collider = null
		elif obstruction.collider != _current_collider:
			_current_collider = obstruction.collider
			var audio_material: AudioMaterial = obstruction.collider.get("audio_material")
			if audio_material:
				var bus_index = AudioServer.get_bus_index(_bus_name)
				for i in range(audio_material.effects.size()):
					AudioServer.add_bus_effect(bus_index, audio_material.effects[i], i)

	# For the other listeners, who don't hear any real sounds, we only need to
	# update frequently enough for their responses to seem realistic.
	for listener in listeners:
		if listener is Ears:
			if not self in listener.sounds:
				listener.hear_sound(self)


func _on_Area_area_entered(area):
	var listener: Listener = area.get_parent()

	if listener:
		listeners.append(listener)
		Logger.trace('%d' % listeners.size(), Logger.CATEGORY_AUDIO)
		# warning-ignore:narrowing_conversion
		_batch_size = ceil(listeners.size() / UPDATE_FREQUENCY)
		Logger.trace(
			"'%s' may hear sound '%s'" % [listener.get_parent().name, name], Logger.CATEGORY_AUDIO
		)

		if listener.is_current():
			current_listener = listener
			Logger.trace("Current listener added to sound '%s'" % name, Logger.CATEGORY_AUDIO)

			# Add a new bus that we can dynamically apply effects to.
			# Reference it by name, as buses may be re-arranged, and send it's
			# output to the SFX bus.
			var bus_index = AudioServer.bus_count
			AudioServer.add_bus(bus_index)
			AudioServer.set_bus_name(bus_index, _bus_name)
			AudioServer.set_bus_send(bus_index, "SFX")
			bus = _bus_name


func _on_Area_area_exited(area):
	var listener: Listener = area.get_parent()

	if listener:
		listeners.erase(listener)
		# warning-ignore:narrowing_conversion
		_batch_size = ceil(listeners.size() / UPDATE_FREQUENCY)
		Logger.trace(
			"'%s' will no longer hear sound '%s'" % [listener.get_parent().name, name],
			Logger.CATEGORY_AUDIO
		)

		if listener.is_current():
			current_listener = null
			# Remove the audio bus added previously.
			bus = "Mute"
			AudioServer.remove_bus(AudioServer.get_bus_index(_bus_name))
			Logger.trace("Current listener removed from sound '%s'" % name, Logger.CATEGORY_AUDIO)

		if listener is Ears and self in listener.sounds:
			listener.unhear_sound(self)


func stop():
	.stop()
	_on_PropagatedSound_finished()


func _on_PropagatedSound_finished():
	for listener in listeners:
		if listener is Ears:
			listener.unhear_sound(self)
