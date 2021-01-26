class_name StatInstance, "../icons/stat_icon.svg"
extends Node

export (Resource) var stat setget set_stat


func set_stat(value):
	if value is Resource:
		if value is Stat:
			stat = value
		else:
			stat = Stat.new()
	else:
		stat = Object()
