#ifndef POSIX_FILE_H
#define POSIX_FILE_H

#include <limits.h>
#include <Godot.hpp>
#include <Node.hpp>
#include <filesystem>

namespace godot {

class PosixFileDirectory;

class PosixFile : public Node {
	GODOT_CLASS(PosixFile, Node)

protected:
	PosixFileDirectory *parent;

public:
	float yolohoo;
	String path;

	static void
	_register_methods();

	PosixFile();
	~PosixFile();
	void _init();
	void _ready();

	String get_dirname();
	void set_filename(String filename);
	String get_filename();
	String get_absolute_path();

	void set_parent_directory(PosixFileDirectory *directory);

	bool is_root_directory;
};
} // namespace godot

#endif // POSIX_FILE_H