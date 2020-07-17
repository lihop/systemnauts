extends Node2D
class_name ProcessMonitors


const font = preload("../fonts/font.tres")

const PID_MAX = 1024
const MONITOR_WIDTH = 208
const MONITOR_HEIGHT = 125
const MONITORS_PER_ROW = 58
const MONITORS_PER_COL = 18


func _ready():
	for pid in range(1, PID_MAX + 1):
		var monitor = Monitor.new(pid)
		add_child(monitor)
	
	Audit.register_watch("/proc", funcref(self, "_update_monitor"))
	_update_all_monitors()


func _update_all_monitors():
	var dir = Directory.new()
	if dir.open("/proc") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var monitor = get_node_or_null(file_name)
				if monitor is Monitor:
					monitor.visible = true
			file_name = dir.get_next()
	else:
		push_error("Error opening /proc directory")


func _update_monitor():
	print("proc_event!")
	pass


func _draw():
	var width = MONITOR_WIDTH * MONITORS_PER_ROW
	var height = MONITOR_HEIGHT * MONITORS_PER_COL
	var background_rect = Rect2(Vector2.ZERO, Vector2(width, height))
	draw_rect(background_rect, Color(0, 0, 0))


class Monitor:
	extends Node2D
	
	
	var pid
	
	
	func _init(pid):
		self.pid = pid
		name = str(pid)
		visible = false
	
	
	func _draw():
		var row_idx = floor((pid - 1.0) / MONITORS_PER_ROW)
		var col_idx = (pid - 1) % 58
		var pos = Vector2(col_idx * MONITOR_WIDTH, row_idx * MONITOR_HEIGHT)
		var size = Vector2(MONITOR_WIDTH, MONITOR_HEIGHT)
		
		var rect = Rect2(pos, size)
		var col = Color(1, 1, 0) if pid == 1 else Color(1, 0, 0)
		draw_rect(rect, col, false, 50)
		
		draw_string(font, pos + Vector2(MONITOR_WIDTH / 2, MONITOR_HEIGHT / 2),
				"%d" % pid, Color(1, 1, 1))
