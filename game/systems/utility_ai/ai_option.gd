class_name AIOption
extends Reference

var decision_name := ""
var score
var action
var params := {}


func _init(decision, params = []):
	action = decision
	decision_name = decision.name
	params = params


class Sorter:
	static func score_descending(option_a: AIOption, option_b: AIOption):
		return option_a.score > option_b.score
