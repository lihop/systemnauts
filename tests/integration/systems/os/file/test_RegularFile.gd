extends "res://addons/gut/test.gd"


signal ready()

const TEMP_TEST_DIRECTORY = "/tmp/gut_test/file_test"
const TEST_FILE = "%s/test_file" % TEMP_TEST_DIRECTORY
const EXAMPLE_FILE = "res://tests/integration/systems/os/file/example_file"
const EXAMPLE_EMPTY_FILE = "res://tests/integration/systems/os/file/example_empty_file"
const HOST = "192.168.56.110"

var machines: Array
var file: RegularFile


func before_all():
	var local_machine = LocalMachine.new()
	
	var remote_machine = RemoteMachine.new()
	remote_machine.public_ipv4 = HOST
	
	machines = [local_machine, remote_machine]
	
	for machine in machines:
		add_child(machine)


func after_all():
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEMP_TEST_DIRECTORY]), "completed")
		remove_child(machine)


func before_each():
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEMP_TEST_DIRECTORY]), "completed")
		yield(machine.execute("mkdir", ["-p", TEMP_TEST_DIRECTORY]), "completed")
	
	file = RegularFile.new()
	file.absolute_path = TEST_FILE
	file.create = false
	file.overwrite = false
	
	emit_signal("ready")


func after_each():
	remove_child(file)


func test_file_exists_when_exists():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("touch", [TEST_FILE]), "completed")
		file.machine = machine.get_path()
		add_child(file)
		assert_true(yield(file._file_exists(), "completed"))


func test_file_exists_when_not_exists():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("rm", ["-rf", TEST_FILE]), "completed")
		file.machine = machine.get_path()
		add_child(file)
		assert_false(yield(file._file_exists(), "completed"))


func test_file_exists_when_not_a_file():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("mkdir", ["-p", TEST_FILE]), "completed")
		file.machine = machine.get_path()
		add_child(file)
		assert_false(yield(file._file_exists(), "completed"))


func test_file_contents_match_when_match():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("cp", [ProjectSettings.globalize_path(EXAMPLE_FILE),
				TEST_FILE]), "completed")
		file.machine = machine.get_path()
		file.contents = EXAMPLE_FILE
		add_child(file)
		assert_true(yield(file._contents_match(), "completed"))


func test_file_contents_match_when_do_not_match():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("touch", [TEST_FILE]), "completed")
		file.machine = machine.get_path()
		file.contents = EXAMPLE_FILE
		add_child(file)
		assert_false(yield(file._contents_match(), "completed"))


func test_create_file_empty():
	yield(self, "ready")
	for machine in machines:
		file.machine = machine.get_path()
		file.create = true
		add_child(file)
		yield(get_tree().create_timer(0.5), "timeout")
		assert_true(yield(file._file_exists(), "completed"))
		file.contents = EXAMPLE_EMPTY_FILE
		assert_true(yield(file._contents_match(), "completed"))


func test_create_file_with_contents():
	yield(self, "ready")
	for machine in machines:
		file.machine = machine.get_path()
		file.contents = EXAMPLE_FILE
		file.create = true
		add_child(file)
		yield(get_tree().create_timer(0.5), "timeout")
		assert_true(yield(file._file_exists(), "completed"))
		assert_true(yield(file._contents_match(), "completed"))


func test_file_delete():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("touch", [TEST_FILE]), "completed")
		file.machine = machine.get_path()
		add_child(file)
		yield(file._delete(), "completed")
		assert_false(yield(file._file_exists(), "completed"))


func test_file_not_overwrite():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("touch", [TEST_FILE]), "completed")
		file.machine = machine.get_path()
		file.contents = EXAMPLE_FILE
		file.create = true
		file.overwrite = false
		add_child(file)
		yield(get_tree().create_timer(0.5), "timeout")
		assert_false(yield(file._contents_match(), "completed"))


func test_file_overwrite():
	yield(self, "ready")
	for machine in machines:
		yield(machine.execute("touch", [TEST_FILE]), "completed")
		file.machine = machine.get_path()
		file.contents = EXAMPLE_FILE
		file.create = true
		file.overwrite = true
		add_child(file)
		yield(get_tree().create_timer(0.5), "timeout")
		assert_true(yield(file._contents_match(), "completed"))
