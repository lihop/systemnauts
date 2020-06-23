#include "audit.h"
#include "gdexample.h"
#include "posix_file.h"
#include "posix_file_directory.h"
#include "terminal.h"

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) {
	godot::Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) {
	godot::Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
	godot::Godot::nativescript_init(handle);

	godot::register_class<godot::GDExample>();

	godot::register_class<godot::Audit>();

	godot::register_class<godot::PosixFile>();

	godot::register_class<godot::PosixFileDirectory>();

	godot::register_class<godot::Terminal>();
}
