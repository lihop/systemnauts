extends "res://addons/gut/test.gd"

const ReGoapAgent = preload("res://addons/ReGoap/Godot/ReGoapAgent.cs")
const SCENE = preload("goap_integration.test.tscn")

var scene
var agent: ReGoapAgent
var sensor


func before_each():
	scene = add_child_autoqfree(SCENE.instance())
	agent = scene.get_node("ReGoapAgent")
	sensor = scene.get_node("Sensor")

	watch_signals(agent)


func test_plan_completed_signal_emitted():
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	assert_signal_emit_count(agent, "PlanningCompleted", 1)


func test_plan_completed_signal_emitted_when_world_state_changes():
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	sensor.set_state("intruderVisible", true)
	agent.CalculateNewGoal(true)
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	assert_signal_emit_count(agent, "PlanningCompleted", 2)


func test_goal_changed_not_emitted_when_goal_did_not_change():
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	sensor.set_state("someUnrelatedState", true)
	agent.CalculateNewGoal(true)
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	assert_signal_emit_count(agent, "GoalChanged", 0)


func test_goal_changed_emitted_when_goal_did_change():
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	sensor.set_state("intruderVisible", true)
	agent.CalculateNewGoal(true)
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	assert_signal_emit_count(agent, "GoalChanged", 1)
	assert_signal_emitted_with_parameters(agent, "GoalChanged", [agent.get_node("IntruderCaught")])


func test_plan_changed_not_emitted_when_plan_did_not_change():
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	sensor.set_state("someUnrelatedState", true)
	agent.CalculateNewGoal(true)
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	assert_signal_emit_count(agent, "PlanChanged", 0)


func test_plan_changed_emitted_when_plan_did_change():
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	sensor.set_state("intruderVisible", true)
	agent.CalculateNewGoal(true)
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	assert_signal_emit_count(agent, "PlanChanged", 1)
	assert_signal_emitted_with_parameters(agent, "PlanChanged", [[agent.get_node("CatchIntruder")]])


func test_nested_goals_and_actions():
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	sensor.set_state("hasJob", true)
	agent.CalculateNewGoal(true)
	yield(yield_to(agent, "PlanningCompleted", 5), YIELD)
	assert_signal_emit_count(agent, "GoalChanged", 1)
	assert_signal_emitted_with_parameters(
		agent, "GoalChanged", [agent.get_node("Nested/HaveMoney")]
	)
