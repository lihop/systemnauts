extends "res://computer/shell/Shell.gd"


# Path where the UNIX domain socket should be created.
export(String) var socket_path = "user://shell-%s.sock" % get_instance_id()
