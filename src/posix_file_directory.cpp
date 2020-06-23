#include "posix_file_directory.h"
#include "audit.h"
#include <SceneTree.hpp>
#include <functional>

using namespace godot;

void PosixFileDirectory::_register_methods() {
	register_signal<PosixFileDirectory>((char *)"file_created", "filename", GODOT_VARIANT_TYPE_STRING);
	register_signal<PosixFileDirectory>((char *)"file_deleted", "filename", GODOT_VARIANT_TYPE_STRING);

	register_property<PosixFileDirectory, bool>("sleep", &PosixFileDirectory::set_sleep, &PosixFileDirectory::get_sleep, true);

	register_method("_init", &PosixFileDirectory::_init);
	register_method("_ready", &PosixFileDirectory::_ready);
	register_method("_exit_tree", &PosixFileDirectory::_exit_tree);
}

void PosixFileDirectory::set_sleep(bool sleep) {
	this->sleep = sleep;

	Audit *audit = Object::cast_to<Audit>(get_node("/root/Audit"));
	if (audit && sleep) {
		audit->unregister_directory(this);
	} else {
		audit->register_directory(this);
	}
}

bool PosixFileDirectory::get_sleep() {
	return this->sleep;
}

PosixFileDirectory::PosixFileDirectory() {

	Godot::print(String("PosixFileDirectory constructed!"));
}

PosixFileDirectory::~PosixFileDirectory() {

	Godot::print(String("PosixFileDirectory deconstructed"));
}

void PosixFileDirectory::_init() {
	sleep = true;
}

void PosixFileDirectory::_ready() {
	PosixFile::_ready();

	add_to_group("posix_file_directories");

	is_root_directory = !parent;

	if (is_root_directory) {
		path = "/";
		update_child_file_parent_directory();

		// First check than the Audit singleton exists.
		Audit *audit = Object::cast_to<Audit>(get_node("/root/Audit"));
		if (!audit) {
			ERR_PRINT("Audit singleton does not exist. Files and directories cannot be monitored for changes");
			return;
		}

		Array directories = get_tree()->get_nodes_in_group("posix_file_directories");
		for (int i = 0; i < directories.size(); i++) {
			PosixFileDirectory *directory = Object::cast_to<PosixFileDirectory>(directories[i]);

			if (directory) {
				directory->start_monitoring();
			}
		}
	}

	// For all files, if this is the parent directory of the child, then set it's path.

	// If it's the root directory, set_path to ("/");
	// This will trigger an update for all the children.
}

void PosixFileDirectory::_exit_tree() {
	Audit *audit = Object::cast_to<Audit>(get_node_or_null("/root/Audit"));
	if (audit) audit->unregister_directory(this);
}

void PosixFileDirectory::start_monitoring() {

	Godot::print(String("starting monitoring for {0}").format(Array::make(path)));
	Audit *audit = Object::cast_to<Audit>(get_node("/root/Audit"));
	audit->register_directory(this);
}

Array PosixFileDirectory::get_file_children() {
	Array file_children = Array::make();

	std::function<void(Node *)> find_file_children;
	find_file_children = [&file_children, &find_file_children](Node *node) -> void {
		if (!node->get_child_count()) return;

		Array children = node->get_children();

		for (int i = 0; i < children.size(); i++) {
			Variant child = children[i];

			if (Object::cast_to<PosixFile>(child)) {
				file_children.append(child);
			} else {
				find_file_children(child);
			}
		}
	};

	find_file_children(this);

	return file_children;
}

void PosixFileDirectory::set_parent_directory(PosixFileDirectory *directory) {
	PosixFile::set_parent_directory(directory);
	update_child_file_parent_directory();
}

void PosixFileDirectory::update_child_file_parent_directory() {
	Array file_children = get_file_children();
	for (int i = 0; i < file_children.size(); i++) {
		PosixFileDirectory *directory = Object::cast_to<PosixFileDirectory>(file_children[i]);
		PosixFile *file = Object::cast_to<PosixFile>(file_children[i]);

		if (directory) {
			directory->set_parent_directory(this);
			Godot::print(String("root setting parent dir of {0}").format(Array::make(directory->get_path())));
		} else {
			file->set_parent_directory(this);
			Godot::print(String("root setting parent dir of {0}").format(Array::make(file->get_path())));
		}
	}
}

void PosixFileDirectory::handle_audit_event(EventType event_type, String filename) {
	String msg;
	switch (event_type) {
		case CREATE:
			msg = String("dir: {0}, handling: {1}, file: {2}").format(Array::make(get_name(), "CREATE", filename));
			emit_signal("file_created", filename);
			break;
		case DELETE:
			msg = String("dir: {0}, handling: {1}, file: {2}").format(Array::make(get_name(), "DELETE", filename));
			emit_signal("file_deleted", filename);
			break;
	}
	Godot::print(msg);
}