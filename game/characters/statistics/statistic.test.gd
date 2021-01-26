extends "res://addons/gut/test.gd"

var statistic


func before_each():
	statistic = Statistic.new()
	statistic.default = 0.5

	var state_above = StatisticState.new()
	state_above.id = "someAboveState"
	state_above.threshold = 1.0

	var state_below = StatisticState.new()
	state_below.id = "someBelowState"
	state_below.threshold = 0.0

	statistic.above.append(state_above)
	statistic.below.append(state_below)

	watch_signals(statistic)
	statistic = add_child_autofree(statistic)


func test_number_of_above_states():
	assert_eq(statistic.above.size(), 1)


func test_number_of_below_states():
	assert_eq(statistic.below.size(), 1)


func test_current_set_to_default():
	assert_eq(statistic.current, 0.5)


func test_adjust_increases_current_value():
	statistic.adjust(+0.4)
	assert_almost_eq(statistic.current, 0.9, 0.001)


func test_adjust_decreases_current_value():
	statistic.adjust(-0.4)
	assert_almost_eq(statistic.current, 0.1, 0.001)


func test_signal_not_emitted_by_default():
	assert_signal_emit_count(statistic, "state_changed", 0)


func test_signal_not_emitted_when_not_above_threshold():
	statistic.adjust(+0.4)
	assert_signal_not_emitted(statistic, "state_changed")


func test_signal_emitted_when_above_threshold():
	statistic.adjust(+0.6)
	assert_signal_emit_count(statistic, "state_changed", 1)
	assert_signal_emitted(statistic, "state_changed")


func test_signal_not_emitted_when_not_below_threshold():
	watch_signals(statistic)
	statistic.adjust(-0.4)
	assert_signal_not_emitted(statistic, "state_changed")


func test_signal_emitted_when_below_threshold():
	watch_signals(statistic)
	statistic.adjust(-10)
	assert_signal_emit_count(statistic, "state_changed", 1)
	assert_signal_emitted(statistic, "state_changed")


func test_signal_not_re_emitted_after_passing_above_threshold_once():
	statistic.adjust(+10)
	statistic.adjust(+10)
	statistic.adjust(+10)
	assert_signal_emit_count(statistic, "state_changed", 1)


func test_signal_not_re_emitted_after_passing_below_threshold_once():
	statistic.adjust(-10)
	statistic.adjust(-10)
	statistic.adjust(-10)
	assert_signal_emit_count(statistic, "state_changed", 1)


func test_signal_emits_when_going_above_and_back_below_threshold():
	statistic.adjust(+10)
	statistic.adjust(+10)
	statistic.adjust(-20)
	assert_signal_emit_count(statistic, "state_changed", 2)


func test_signal_emits_when_going_below_and_back_above_threshold():
	statistic.adjust(-10)
	statistic.adjust(-10)
	statistic.adjust(+20)
	assert_signal_emit_count(statistic, "state_changed", 2)


func test_correct_signal_params_above_threshold():
	statistic.adjust(+10)
	assert_signal_emitted_with_parameters(statistic, "state_changed", ["someAboveState", true])


func test_correct_signal_params_below_threshold():
	statistic.adjust(-10)
	assert_signal_emitted_with_parameters(statistic, "state_changed", ["someBelowState", true])
