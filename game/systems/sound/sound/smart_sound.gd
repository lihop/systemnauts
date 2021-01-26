class_name SmartSound
extends PropagatedSound
# A SmartSound is a PropagatedSound that can have certain effects on the stats
# or knowlegde of agents that hear them. For example, hearing an explosion could
# might increase the Fear or Alertness stats of an agent. Hearing a ringing sound
# might update their knowlege about a Phone object that it is ringing (which could
# be a catalyst for triggering an 'answer phone' behavior).

export (NodePath) var object_node := NodePath("..")
export (Array, Resource) var heard_effects := []
export (Array, Resource) var unheard_effects := []

# Hearing this sound will update that agents knowledge of the listed properties.
# For example, hearing a malfunction sound would alert an agent that a SmartObject
# is broken, or hearing a ringing sound would alert an agent that a SmartObject
# is alerting.
export (Array, String) var propagated_properties := []

onready var object: SmartObject = get_node(object_node)
