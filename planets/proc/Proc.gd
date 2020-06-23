extends RigidBody


const Pid = preload("./pid/Pid.tscn")


export(NodePath) var proc_notifier

onready var _proc_notifier = get_node(proc_notifier)


func _ready():
	_proc_notifier.connect("process_forked", self, "_on_process_forked")
