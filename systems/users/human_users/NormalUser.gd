extends User
class_name NormalUser
# Base class for "real" users (e.g. human) that have a home directory and shell
# as opposed to system users.


# A list of OpenSSH public keys that will be added to the user's authorized keys.
var authorized_keys := PoolStringArray([])
