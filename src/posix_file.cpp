#include "posix_file.h"
#include "posix_file_directory.h"
#include <libgen.h>
#include <functional>

using namespace godot;

void PosixFile::_register_methods() {
	register_method("_init", &PosixFile::_init);
	register_method("_ready", &PosixFile::_ready);
	register_method("get_absolute_path", &PosixFile::get_absolute_path);

	register_property<PosixFile, float>("yolohoo", &PosixFile::yolohoo, 5.0);
}

PosixFile::PosixFile() {

	Godot::print(String("PosixFile constructed!"));
}

PosixFile::~PosixFile() {

	Godot::print(String("PosixFile deconstructed"));
}

void PosixFile::_init() {
	yolohoo = 5.0;
}

void PosixFile::_ready() {
	Godot::print("Starting _ready() of PosixFile!");

	set_filename(get_name());
	add_to_group("posix_files");

	// We need to get the path of this file.
	// Start by printing the node path in the tree,
	// then loop through each node and check it's type is PosixFileDirectory to construct path based purely on directory structure.
	NodePath path = get_path();
	Godot::print(String("path to this PosixFile: {0}").format(Array::make(path)));

	// Iterate up the path until we hit a PosixFileDirectory. That directory will be this nodes parent.
	// If we don't find a directory, then this node MUST be the root directory (i.e. /).
	std::function<PosixFileDirectory *(Node *)> get_parent_directory;
	get_parent_directory = [&get_parent_directory](Node *node) -> PosixFileDirectory * {
		Node *parent = node->get_parent();

		if (!parent) {
			return nullptr;
		}

		PosixFileDirectory *directory = Object::cast_to<PosixFileDirectory>(parent);

		if (!directory) {
			return get_parent_directory(parent);
		} else {
			return directory;
		}

		return nullptr;
	};

	parent = get_parent_directory(this);

	if (parent) {
		if (parent->is_root_directory) {
			path = String("/{0}").format(get_name());
		} else {
			path = String("{0}/{1}").format(parent->path, get_name());
		}
	}
}

String PosixFile::get_dirname() {
	return String(dirname(path.alloc_c_string()));
}

void PosixFile::set_parent_directory(PosixFileDirectory *directory) {
	if (directory->is_root_directory) {
		path = String("/{0}").format(Array::make(get_filename())).alloc_c_string();

	} else {
		path = String("{0}/{1}").format(Array::make(directory->path, get_filename())).alloc_c_string();
	}
}

void PosixFile::set_filename(String filename) {
	path = String("{0}/{1}").format(Array::make(get_dirname(), filename));
}

String PosixFile::get_filename() {
	return String(basename(path.alloc_c_string()));
}

String PosixFile::get_absolute_path() {
	return path;
}