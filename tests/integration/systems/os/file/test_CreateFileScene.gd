extends "res://addons/gut/test.gd"


signal ready()

const TEMP_TEST_DIRECTORY = "/tmp/gut_test/CreateFileScene"
const SCENE = preload("res://tests/integration/systems/os/file/CreateFileScene.tscn")
const HOST = "192.168.56.110"

var machines: Array

var scene


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
	
	scene = SCENE.instance()
	emit_signal("ready")


func after_each():
	remove_child(scene)


func test_scene_creates_directory():
	yield(self, "ready")
	add_child(scene)
	yield(get_tree().create_timer(1), "timeout")
	var result = yield(WorldMachine.machine.execute("sh",
			["-c", "\"'[ -d %s/Directory ]'\"" % TEMP_TEST_DIRECTORY]),
			"completed")
	assert_eq(result.exit_code, 0)


func test_scene_creates_sub_directory():
	yield(self, "ready")
	add_child(scene)
	yield(get_tree().create_timer(1), "timeout")
	var result = yield(WorldMachine.machine.execute("sh",
			["-c", "\"'[ -d %s/Directory/SubDirectory ]'\"" % TEMP_TEST_DIRECTORY]),
			"completed")
	assert_eq(result.exit_code, 0)


func test_scene_creates_file():
	yield(self, "ready")
	add_child(scene)
	yield(get_tree().create_timer(1), "timeout")
	var result = yield(WorldMachine.machine.execute("sh",
			["-c", "\"'[ -f %s/Directory/File ]'\"" % TEMP_TEST_DIRECTORY]),
			"completed")
	assert_eq(result.exit_code, 0)
