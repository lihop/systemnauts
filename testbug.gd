extends Node
# Interface to the inotifywait program. Waits for changes to files using inotify
# and calls the registered handlers.
# Reference: http://man7.org/linux/man-pages/man1/inotifywait.1.html


const Tunes = {
	TYPE_LINUX = "cool"
}

# A watched file or a file within a watched directory was read from.
const EVENT_ACCESS = "accessed"

# A watched file or a file within a watched directory was written to.
const EVENT_MODIFY = "modified"

# The metadata of a watched file or a file within a watched directory was modified.
const EVENT_ATTRIB = "attributes_modified"

# A watched file or a file within a watched directory was closed, after being
# opened in writable mode. This does not necessarily imply the file was written to.
const EVENT_CLOSE_WRITE = "write_closed"

# A watched file or a file within a watched directory was closed, after being
# opened in read-only mode.
const EVENT_CLOSE_NOWRITE = "nowrite_closed"
