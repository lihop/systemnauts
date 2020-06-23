#ifndef POSIX_FILE_DIRECTORY_H
#define POSIX_FILE_DIRECTORY_H

#include "audit.h"
#include "posix_file.h"
#include <Godot.hpp>

namespace godot {

class PosixFileDirectory : public PosixFile {
	GODOT_CLASS(PosixFileDirectory, PosixFile)

private:
	void
	start_monitoring();
	Array get_file_children();
	void update_child_file_parent_directory();

	bool sleep;

public:
	static void
	_register_methods();

	PosixFileDirectory();
	~PosixFileDirectory();

	void set_sleep(bool sleep);
	bool get_sleep();

	void _init();
	void _ready();
	void _exit_tree();

	void set_parent_directory(PosixFileDirectory *directory);

	enum EventType {
		CREATE,
		DELETE,
	};

	void handle_audit_event(PosixFileDirectory::EventType event_type, String filename);
};
} // namespace godot

#endif // POSIX_FILE_DIRECTORY_H