extends Node
class_name ShellStream

signal data_received(data)

export(String) var command


func put_data(data: PoolByteArray) -> void:
	pass
