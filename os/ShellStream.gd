extends Node
class_name ShellStream

signal data_received(data)

export(String) var command


func put_data(data: PoolByteArray) -> void:
	pass


# Convenience wrapper around put_data that accepts a string rather than
# PoolByteArray.
func put_string(string: String) -> void:
	put_data(string.to_utf8())
