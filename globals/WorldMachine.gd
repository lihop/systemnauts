extends Node


# The machine in which the world exists.
var machine: Machine


func _ready():
	if OS.has_feature("Server"):
		machine = LocalMachine.new()
	else:
		machine = RemoteMachine.new()
		machine.public_ipv4 = "192.168.56.110"
	
	machine.name = "machine"
	add_child(machine)
