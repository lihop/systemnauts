#include "audit.h"
#include <auparse.h>
#include <errno.h>
#include <libaudit.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <unistd.h>
#include <OS.hpp>
#include <core/Array.hpp>
#include <core/String.hpp>
#include <filesystem>
#include <iostream>

using namespace godot;

std::map<String, PosixFileDirectory *> Audit::directories = {};

void Audit::_register_methods() {
	register_method("_init", &Audit::_init);
	register_method("_ready", &Audit::_ready);
	register_method("_process", &Audit::_process);
}

Audit::Audit() {
	Godot::print(String("Audit constructed!"));
}

Audit::~Audit() {

	// // /* Flush any accumulated events from queue */
	// // auparse_flush_feed(au);
	// // auparse_destroy(au);

	// /* Delete all rules */
	// std::system("auditctl -D");
	Godot::print(String("Audit deconstructed"));
}

void Audit::_init() {

	/* Delete all rules */
	std::system("auditctl -D");

	/* Initialize the socket connection */
	Godot::print(String("Audit: begin init"));

	sock = socket(AF_UNIX, SOCK_STREAM | SOCK_NONBLOCK, 0);
	if (sock < 0) {
		ERR_PRINT(String("Error opening stream socket: {0}").format(Array::make(strerror(errno))));
	}
	dup2(sock, 0); // Duplicate the socket to stdin so we can read it with fgets().
	Godot::print(String("stream socket opened"));

	server.sun_family = AF_UNIX;
	strcpy(server.sun_path, "/var/run/audispd_events");

	int err = ::connect(sock, (struct sockaddr *)&server, sizeof(struct sockaddr_un));
	if (err < 0) {
		ERR_PRINT(String("Error connecting stream socket: {0}").format(Array::make(strerror(errno))));
	}
	Godot::print(String("stream socket connected"));

	/* Initialize the auparse library */

	// au = auparse_init(AUSOURCE_FEED, 0);
	// if (au == NULL) {
	// 	ERR_PRINT("Error initializing event source");
	// }
	// auparse_add_callback(au, handle_event, this, NULL);
	// Godot::print(String("auparse library initialized"));
}

void Audit::_ready() {
	if (OS::get_singleton()->has_feature("Server")) {
		auditing = true;
		audit_thread = std::thread(&Audit::process_audit_log, this);
	} else {
		auditing = false;
	}
}

void Audit::process_audit_log() {
	auparse_state_t *au = NULL;
	char buf[MAX_AUDIT_MESSAGE_LENGTH + 1];

	/* Initialize the auparse library */
	au = auparse_init(AUSOURCE_FEED, 0);
	auparse_add_callback(au, handle_event, this, NULL);

	/* Add one rule to rule them all */
	std::system("auditctl -a always,exit -F dir=/ -p rwxa -F success=1");

	while (auditing) {
		int ready = -1;
		fd_set read_fds;

		FD_ZERO(&read_fds);
		FD_SET(0, &read_fds);

		do {
			ready = select(1, &read_fds, NULL, NULL, NULL);
		} while (ready == -1 && errno == EINTR);

		if (ready > 0) {
			if (fgets_unlocked(buf, MAX_AUDIT_MESSAGE_LENGTH, stdin)) {
				auparse_feed(au, buf, strnlen(buf, MAX_AUDIT_MESSAGE_LENGTH));
			}
		} else if (ready == 0) {
			auparse_flush_feed(au);
		}

		if (feof(stdin)) {
			std::lock_guard<std::mutex> lock(auditing_mutex);
			auditing = false;
		}
	}

	std::system("auditctl -D");
	auparse_flush_feed(au);
	auparse_destroy(au);
}

void Audit::_process(float delta) {
}

void Audit::handle_event(auparse_state_t *au, auparse_cb_event_t cb_event_type, void *user_data) {
	if (cb_event_type != AUPARSE_CB_EVENT_READY)
		return;

	AuditEvent audit_event{ type : AUDIT_EVENT_OTHER };

	char *dirname, *filename, *nametype = NULL;
	PosixFileDirectory::EventType event_type;

	// First try to get cwd.
	auparse_first_record(au);
	if (auparse_find_field(au, "cwd")) {
		dirname = strdup(auparse_interpret_field(au));
	}

	// Now try to figure out if it was a CREATE or DELETE
	auparse_first_record(au);
	if (auparse_find_field(au, "nametype")) {
		do {
			nametype = strdup(auparse_interpret_field(au));
			if (strcmp(nametype, "CREATE") == 0)
				break;
			if (strcmp(nametype, "DELETE") == 0)
				break;
			nametype = NULL;
		} while (auparse_find_field_next(au));
	}

	// Now try to get something else with normalize funcs.
	auparse_first_record(au);
	auparse_normalize(au, NORM_OPT_NO_ATTRS);
	if (auparse_normalize_object_primary(au) == 1) {
		filename = strdup(auparse_interpret_field(au));
	}

	if (dirname != NULL && filename != NULL && nametype != NULL) {
		if (strcmp(nametype, "CREATE") == 0) {
			event_type = PosixFileDirectory::EventType::CREATE;
		} else if (strcmp(nametype, "DELETE") == 0) {
			event_type = PosixFileDirectory::EventType::DELETE;
		} else {
			return;
		}

		PosixFileDirectory *directory = Audit::directories[String(dirname)];

		if (directory) {
			directory->handle_audit_event(event_type, basename(filename));
		}
	}
}

void Audit::register_directory(PosixFileDirectory *directory) {
	//int fd = audit_open();
	//if (fd < 0) {
	//	ERR_PRINT(String("Error: {0}").format(Array::make(strerror(errno))));
	//} else {
	//	Godot::print("Opened audit!");
	//}

	//struct audit_rule_data *rule = create_rule_data(directory);

	//if (audit_add_rule_data(fd, rule, AUDIT_FILTER_EXIT, AUDIT_ALWAYS) < 0) {
	//	Godot::print("error adding rule data!");
	//	ERR_PRINT(String("Error adding rule data: {0}").format(Array::make(strerror(errno))));
	//}

	//audit_close(fd);

	Audit::directories[directory->path] = directory;
}

void Audit::unregister_directory(PosixFileDirectory *directory) {

	int fd = audit_open();
	if (fd < 0) {
		ERR_PRINT(String("Error: {0}").format(Array::make(strerror(errno))));
	} else {
		Godot::print("Opened audit!");
	}

	struct audit_rule_data *rule = create_rule_data(directory);

	if (audit_delete_rule_data(fd, rule, AUDIT_FILTER_EXIT, AUDIT_ALWAYS) < 0) {
		Godot::print("error adding rule data!");
		ERR_PRINT(String("Error adding rule data: {0}").format(Array::make(strerror(errno))));
	}

	audit_close(fd);

	directories.erase(directory->get_instance_id());
}

struct audit_rule_data *Audit::create_rule_data(PosixFileDirectory *directory) {
	struct audit_rule_data *rule = new audit_rule_data();
	if (audit_add_watch_dir(AUDIT_DIR, &rule, directory->get_absolute_path().alloc_c_string()) < 0) {
		Godot::print("error adding watch dir!");
	}

	/* Add key (use instance id) */
	char *cmd = NULL;
	if (asprintf(&cmd, "key=%d", directory->get_instance_id()) < 0) {
		ERR_PRINT(String("Error adding key to rule: {0}").format(Array::make(strerror(errno))));
	}
	if (audit_rule_fieldpair_data(&rule, cmd, 0) != 0) {
		ERR_PRINT(String("Error adding key to rule: {0}").format(Array::make(strerror(errno))));
	}

	return rule;
}