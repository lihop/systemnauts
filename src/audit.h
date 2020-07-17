#ifndef AUDIT_H
#define AUDIT_H

#include "posix_file_directory.h"
#include <auparse.h>
#include <libaudit.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <FuncRef.hpp>
#include <Godot.hpp>
#include <Node.hpp>
#include <String.hpp>
#include <filesystem>
#include <map>
#include <mutex>
#include <thread>

namespace godot {

class PosixFileDirectory;

class Audit : public Node {
	GODOT_CLASS(Audit, Node)

private:
	int sock;
	struct sockaddr_un server;
	char buf[1024];

	//auparse_state_t *au = NULL;
	//char tmp[MAX_AUDIT_MESSAGE_LENGTH + 1];
	static void handle_event(auparse_state_t *au, auparse_cb_event_t cb_event_type, void *user_data);

	struct audit_rule_data *create_rule_data(PosixFileDirectory *directory);

	static std::map<String, PosixFileDirectory *> directories;

	static std::map<String, std::vector<Ref<FuncRef> > > watches;

	bool auditing;
	std::mutex auditing_mutex;

	std::thread audit_thread;
	void process_audit_log();

public:
	static void
	_register_methods();

	Audit();
	~Audit();
	void _init();

	void _ready();
	void _process(float delta);

	void register_directory(PosixFileDirectory *directory);
	void unregister_directory(PosixFileDirectory *directory);

	void register_watch(String path, Variant callback);
	void unregister_watch(String path, Variant callback);

	enum AuditEventType {
		AUDIT_EVENT_OTHER,
		AUDIT_EVENT_CREATE,
		AUDIT_EVENT_DELETE,
		AUDIT_EVENT_ATTRIBUTE,
	};

	struct AuditEvent {
		AuditEventType type;
		String path;
		String name;
		String cwd;
	};
};
} // namespace godot

#endif // AUDIT_H
