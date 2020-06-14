extends User
class_name NormalUser
# Base class for "real" users (e.g. human) that have a home directory and shell
# as opposed to system users.


# Signal emitted when the users types something. Should probably sent to a shell
# of some sort.
signal typed(text)

export(NodePath) var shell

var _shell: ShellStream

# A list of OpenSSH public keys that will be added to the user's authorized keys.
var authorized_keys := PoolStringArray([])


func type(text: String):
	_shell = get_node_or_null(shell)
	
	if _shell:
		_shell.put_data(text.to_utf8())
