extends Node
class_name Inotifier
# Interface to the inotifywait program. Waits for changes to files using inotify
# and calls the registered handlers.
# Reference: http://man7.org/linux/man-pages/man1/inotifywait.1.html


const Events = {
	# A watched file or a file within a watched directory was read from.
	ACCESS = "accessed",
	
	# A watched file or a file within a watched directory was written to.
	MODIFY = "modified",
	
	# The metadata of a watched file or a file within a watched directory was modified.
	ATTRIB = "attributes_modified",
	
	# A watched file or a file within a watched directory was closed, after being
	# opened in writable mode. This does not necessarily imply the file was written to.
	CLOSE_WRITE = "write_closed",
	
	# A watched file or a file within a watched directory was closed, after being
	# opened in read-only mode.
	CLOSE_NOWRITE = "nowrite_closed",
	
	# A watched file or a file within a watched directory was closed, regardless
	# of how it was opened. Note that this is actually implemented simply by listening
	# for both CLOSE_WRITE and CLOSE_NOWRITE, hence all close events received will
	# be output as one of these, not CLOSE.
	CLOSE = "closed",
	
	# A watched file or a file within a watched directory was opened.
	OPEN = "opened",
	
	# A file or directory was moved into a watched directory. This event occurs
	# even if the file is simply moved from and to the same directory.
	MOVED_TO = "moved_to",
	
	# A file or directory was moved from a watched directory. This event occurs
	# even if the file is simply moved from and to the same directory.
	MOVED_FROM = "moved_from",
	
	# A file or directory was moved from or to a watched directory. Note that this
	# is actually implemented simply by listening for both moved_to and moved_from,
	# hence all MOVE events received will be output as one or both of these, not MOVE.
	MOVE = "moved",
	
	# A watched file or directory was moved. After this event, the file or directory
	# is no longer being watched.
	MOVE_SELF = "moved_self",
	
	# A file or direcory was created within a watched directory.
	CREATE = "created",
	
	# A file or directory within a watched directory was deleted.
	DELETE = "deleted",
	
	# A watched file or directory was deleted. After this event the file or directory
	# is no longer being watched. Note that this event can occur even if it is not
	# explicitly being listened for.
	DELETE_SELF = "deleted_self",
	
	# The filesystem on which a watched file or directory resides was unmonuted.
	# After this event the file or directory is no longer being watched. Note that
	# this event can occur even if itis not explicitly being listened to.
	UNMOUNT = "unmounted",
}

const EVENT_ACCESS = Events.ACCESS
const EVENT_MODIFY = Events.MODIFY
const EVENT_ATTRIB = Events.ATTRIB
const EVENT_CLOSE_WRITE = Events.CLOSE_WRITE
const EVENT_CLOSE_NOWRITE = Events.CLOSE_NOWRITE
const EVENT_CLOSE = Events.CLOSE
const EVENT_OPEN = Events.OPEN
const EVENT_MOVED_TO = Events.MOVED_TO
const EVENT_MOVED_FROM = Events.MOVED_FROM
const EVENT_MOVE = Events.MOVE
const EVENT_MOVE_SELF = Events.MOVE_SELF
const EVENT_CREATE = Events.CREATE
const EVENT_DELETE = Events.DELETE
const EVENT_DELETE_SELF = Events.DELETE_SELF
const EVENT_UNMOUNT = Events.UNMOUNT

const COMMAND_FORMAT = "inotifywait -q -m %s --format='%%w\ue000%%e\ue000%%f\ue000'"

export(NodePath) var directory_watcher_factory

onready var _directory_watcher_factory: DirectoryWatcherFactory = get_node(directory_watcher_factory)

var _event_regex: RegEx = RegEx.new()
var _watchers: Dictionary = {}


class Watcher:
	extends Node
	
	
# warning-ignore:unused_signal
	signal accessed(file)
# warning-ignore:unused_signal
	signal modified(file)
# warning-ignore:unused_signal
	signal attributes_modified(file)
# warning-ignore:unused_signal
	signal write_closed(file)
# warning-ignore:unused_signal
	signal nowrite_closed(file)
# warning-ignore:unused_signal
	signal closed(file)
# warning-ignore:unused_signal
	signal opened(file)
# warning-ignore:unused_signal
	signal moved_to(file)
# warning-ignore:unused_signal
	signal moved_from(file)
# warning-ignore:unused_signal
	signal moved(file)
# warning-ignore:unused_signal
	signal moved_self(file)
# warning-ignore:unused_signal
	signal created(file)
# warning-ignore:unused_signal
	signal deleted(file)
# warning-ignore:unused_signal
	signal deleted_self(file)
# warning-ignore:unused_signal
	signal unmounted(file)
# warning-ignore:unused_signal
	signal event_occured(event, file)
	
	
	func connect_event(event, target: Object, method: String) -> void:
		if event == null:
			connect("event_occured", target, method)
		elif Events.values().has(event):
			# Connect a single event.
			connect(event, target, method)
		else:
			# Invalid event.
			push_warning("Invalid event '%s'. No signal will be emitted" % event)


class DirectoryWatcher:
	extends Watcher
	# Base class for DirectoryWatcher nodes. Emits signals for events which
	# occur on a directory and files within that directory.
	
	var directory: String
	
	var _regex: RegEx = RegEx.new()
	var _file_watchers = {}
	
	
	func _ready():
		_regex.compile("(^%s/{0,1})\ue000(?<event_names>.*)\ue000(?<event_filename>.*)\ue000.*" % directory)
	
	
	func connect_file_event(file, event, target, method):
		var watcher = _file_watchers.get(file)
		
		if not watcher:
			watcher = Watcher.new()
			_file_watchers[file] = watcher
			add_child(watcher)
		
		watcher.connect_event(event, target, method)
	
	
	func _parse(output) -> void:
		if typeof(output) == TYPE_RAW_ARRAY:
			output = output.get_string_from_utf8()
		
		if typeof(output) != TYPE_STRING:
			return
		
		var matches = _regex.search_all(output)
		
		for m in matches:
			var watched_filename = m.get_string("watched_filename")
			var events = m.get_string("event_names").split(",")
			var event_filename = m.get_string("event_filename")
			for event in events:
				if not Events.has(event):
					continue
				emit_signal("event_occured", event_filename, Events[event])
				emit_signal(Events[event], event_filename)
				if _file_watchers.has(event_filename):
					var file_watcher = _file_watchers.get(event_filename)
					file_watcher.emit_signal("event_occured", Events[event])
					file_watcher.emit_signal(Events[event])


class DirectoryWatcherFactory:
	extends Node
	# Factory class for creating instances of DirectoryWatcher.
	
	
	func create_new(directory) -> DirectoryWatcher:
		return DirectoryWatcher.instance()


func add_event_handler(directory: String, target: Object, method: String,
		event = null):
	var watcher = _get_directory_watcher(directory)
	watcher.connect_event(event, target, method)


func add_file_event_handler(directory: String, file: String, target: Object,
		method: String, event = null) -> void:
	var watcher = _get_directory_watcher(directory)
	watcher.connect_file_event(file, event, target, method)


func _get_directory_watcher(directory: String):
	var watcher = _watchers.get(directory)
	
	if not watcher:
		watcher = _directory_watcher_factory.create_new(directory)
		_watchers[directory] = watcher
		add_child(watcher)
	
	return watcher
