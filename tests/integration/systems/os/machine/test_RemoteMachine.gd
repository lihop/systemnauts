extends "res://addons/gut/test.gd"


# TODO: Don't hardcode host and hostname.
const HOST = "192.168.56.110"
const HOSTNAME = "nix"

var machine: RemoteMachine


func before_each():
	machine = RemoteMachine.new()
	machine.public_ipv4 = HOST
	add_child(machine)


func test_execute_true():
	var result = yield(machine.execute("true"), "completed")
	assert_eq(result.exit_code, 0)
	assert_eq(result.output, [""])


func test_execute_false():
	var result = yield(machine.execute("false"), "completed")
	assert_eq(result.exit_code, 1)
	assert_eq(result.output, [""])


func test_execute_long_running_command():
	var result = yield(machine.execute("sleep", [2]), "completed")
	assert_eq(result.exit_code, 0)
	assert_eq(result.output, [""])


func test_execute_whoami():
	var result = yield(machine.execute("whoami"), "completed")
	assert_eq(result.exit_code, 0)
	assert_eq(result.output, ["root"])

func test_execute_whoami_as_another_user():
	var user = OS.get_environment("USER")
	var result = yield(machine.execute("whoami", [], user), "completed")
	assert_eq(result.exit_code, 0)
	assert_eq(result.output, [user])


func test_execute_hostname():
	var result = yield(machine.execute("hostname"), "completed")
	assert_eq(result.exit_code, 0)
	assert_eq(result.output, [HOSTNAME])
