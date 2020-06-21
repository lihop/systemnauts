extends "res://addons/gut/test.gd"


var machine: LocalMachine


func before_each():
	machine = LocalMachine.new()
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
	assert_eq(result.output, [OS.get_environment("USER")])
