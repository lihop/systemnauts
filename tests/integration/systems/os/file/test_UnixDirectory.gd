extends "res://addons/gut/test.gd"


const TEMP_DIRECTORY = "/tmp/gut_test"
const TEST_DIRECTORY = "%s/directory_test" % TEMP_DIRECTORY
const HOST = "192.168.56.110"

var machines: Array
var directory: UnixDirectory


func before_all():
	var local_machine = LocalMachine.new()
	
	var remote_machine = RemoteMachine.new()
	remote_machine.public_ipv4 = HOST
	
	machines = [local_machine, remote_machine]
	
	for machine in machines:
		add_child(machine)


func before_each():
	directory = UnixDirectory.new()
	directory.absolute_path = TEST_DIRECTORY
	directory.create = false
	directory.overwrite = false


func test_file_exists_when_exists():
	for machine in machines:
		directory.machine = machine.get_path()
		yield(machine.execute("rm", ["-rf", TEST_DIRECTORY]), "completed")
		yield(machine.execute("mkdir", ["-p", TEST_DIRECTORY]), "completed")
		add_child(directory)
		assert_true(yield(directory._file_exists(), "completed"))
		remove_child(directory)


func test_file_exists_when_not_exists():
	for machine in machines:
		directory.machine = machine.get_path()
		yield(machine.execute("rm", ["-rf", TEST_DIRECTORY]), "completed")
		add_child(directory)
		assert_false(yield(directory._file_exists(), "completed"))
		remove_child(directory)


func test_file_exists_when_not_a_directory():
	for machine in machines:
		directory.machine = machine.get_path()
		yield(machine.execute("rm", ["-rf", TEST_DIRECTORY]), "completed")
		yield(machine.execute("touch", [TEST_DIRECTORY]), "completed")
		add_child(directory)
		assert_false(yield(directory._file_exists(), "completed"))
		remove_child(directory)


func test_create_directory():
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEST_DIRECTORY]), "completed")
		directory.machine = machine.get_path()
		directory.create = true
		add_child(directory)
		yield(get_tree().create_timer(1), "timeout")
		assert_true(yield(directory._file_exists(), "completed"))
		remove_child(directory)


func test_delete_directory():
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEST_DIRECTORY]), "completed")
		directory.machine = machine.get_path()
		directory.create = true
		add_child(directory)
		yield(get_tree().create_timer(1), "timeout")
		yield(directory._delete(), "completed")
		assert_false(yield(directory._file_exists(), "completed"))
		remove_child(directory)


func test_create_directory_overwrite():
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEST_DIRECTORY]), "completed")
		yield(machine.execute("touch", [TEST_DIRECTORY]), "completed")
		directory.machine = machine.get_path()
		directory.create = true
		directory.overwrite = true
		add_child(directory)
		yield(get_tree().create_timer(1), "timeout")
		assert_true(yield(directory._file_exists(), "completed"))
		remove_child(directory)


func test_create_directory_not_overwrite():
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEST_DIRECTORY]), "completed")
		yield(machine.execute("touch", [TEST_DIRECTORY]), "completed")
		directory.machine = machine.get_path()
		directory.create = true
		directory.overwrite = false
		add_child(directory)
		yield(get_tree().create_timer(1), "timeout")
		assert_false(yield(directory._file_exists(), "completed"))
		remove_child(directory)


func after_all():
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEMP_DIRECTORY]), "completed")
