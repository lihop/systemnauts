extends Node
class_name Shell


export(String) var user := ""
export(String) var command := "bash"


signal data_received(data)


func _ready():
	pass


func send_data(data: PoolByteArray) -> void:
	pass


func _exit_tree():
	pass
