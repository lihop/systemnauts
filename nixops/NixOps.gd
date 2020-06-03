extends Node


export(String) var statefile := "user://state.nixops";

# Operating system functions to use.
var os = OS;

var _deployments := {};
var _statefile_globalized: String


func _ready():
	# Always ensure the state file exists.
	var _statefile = ProjectSettings.globalize_path(statefile)
	os.execute("touch", [_statefile_globalized], false);


func execute_nixops(subcommand: String, arguments: PoolStringArray = [],
		blocking: bool = true, output: Array = []):
	var args = PoolStringArray([subcommand])
	args.append_array(PoolStringArray(["-s", _statefile_globalized]))
	args.append_array(arguments)
	
	return os.execute("nixops", args, blocking, output)


# List all known deployments.
func list():
	var json = []
	execute_nixops("export", ["--all"], true, json);
	var data = JSON.parse(json[0])
	
	for key in data.result.keys():
		print(key)


# Create a new deployment.
func create(deployment_name: String, nix_files: PoolStringArray = []):
	var args = PoolStringArray(["-d", deployment_name])
	args.append_array(nix_files)
	execute_nixops("create", args)


# Modify an existnig deployment.
func modify():
	pass


# Show the state of the deployment.
func info():
	pass


# Check the state of the machines in the network.
func check():
	pass
