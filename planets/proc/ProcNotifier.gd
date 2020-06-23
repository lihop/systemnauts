extends Node
class_name ProcNotifier
# This class watches for proc events.
# TODO: Implement this class as a C++ module.


# PROC_EVENT_FORK - we have a new pid!
# PROC_EVENT_EXIT - a pid was removed.


signal process_forked(pid)
signal process_executed(pid)
signal process_exited(pid)
