# Copyright (c) 2019 The xterm.js authors. All rights reserved.
# Ported to GDScript by the GodotXterm authors.
# License MIT
extends Reference


# Max value supported for a single param/subparam (clamped to positive int32 range).
const MAX_VALUE = 0x7FFFFFFF;
# Max allowed subparams for a single sequence (hardcoded limitation).
const MAX_SUBPARAMS = 256;

var params = []
var length = 0

var sub_params = []
var sub_params_length = 0
var _max_length
var _max_sub_params_length
var sub_params_idx = []
var _reject_digits = false
var _reject_sub_digits = false
var digit_is_sub = false


static func from_array(values: Array):
	# Workaround as per: https://github.com/godotengine/godot/issues/19345#issuecomment-471218401
	var params = load("res://addons/godot_xterm/parser/params.gd").new()
	if values.empty():
		return params
	# skip leading sub params
	for i in range(values.size()):
		var value = values[i]
		if typeof(value) == TYPE_ARRAY:
			if i == 0:
				# skip leading sub params
				continue
			else:
				for sub_param in value:
					params.add_sub_param(sub_param)
		else:
			params.add_param(value)
	return params


func _init(max_length: int = 32, max_sub_params_length: int = 32):
	_max_length = max_length
	_max_sub_params_length = max_sub_params_length
	
	if (max_sub_params_length > MAX_SUBPARAMS):
		push_error("max_sub_params_length must not be greater than 256")
	
	params.resize(max_length)
	sub_params.resize(max_sub_params_length)
	sub_params_idx.resize(max_length)


# Gets param at `index` from param if it exists and is non-zero.
# Otherwise returns `default` (which is zero anyway due to zero default
# mode (ZDM), but allows the caller to specify a non-zero default value).
func get_param(index: int, default = 0) -> int:
	if index < params.size() and params[index]:
		return params[index]
	else:
		return default


func add_param(value: int):
	digit_is_sub = false
	if length >= _max_length:
		_reject_digits = true
		return
	if value < -1:
		push_error('values lesser than -1 are not allowed')
	sub_params_idx[length] = sub_params_length << 8 | sub_params_length
	params[length] = MAX_VALUE if value > MAX_VALUE else value
	length += 1


# Add a sub parameter value.
# The sub parameter is automatically associated with the last parameter value.
# Thus it is not possible to add a subparameter without any parameter added yet.
# `Params` only stores up to `subParamsLength` sub parameters, any later
# sub parameter will be ignored.
func add_sub_param(value: int):
	digit_is_sub = true
	if !length:
		return
	if _reject_digits or sub_params_length >= _max_sub_params_length:
		_reject_sub_digits = true
		return
	if value < -1:
		push_error('values lesser than -1 are not allowed')
	sub_params[sub_params_length] = MAX_VALUE if value > MAX_VALUE else value
	sub_params_length += 1
	sub_params_idx[length - 1] += 1


# Whether parameter at index `idx` has sub parameters.
func has_sub_params(idx: int) -> bool:
	return (sub_params_idx[idx] & 0xFF) - (sub_params_idx[idx] >> 8) > 0


func get_sub_params(idx: int):
	var start = sub_params_idx[idx] >> 8
	var end = sub_params_idx[idx] & 0xFF
	if end - start > 0:
		return sub_params.slice(start, end - 1)
	else:
		return null


func add_digit(value: int):
	var _length = sub_params_length if digit_is_sub else length
	if _reject_digits or (not _length) or (digit_is_sub and _reject_sub_digits):
		return
	var store = sub_params if digit_is_sub else params
	var cur = store[_length - 1]
	store[_length - 1] = min(cur * 10 + value, MAX_VALUE) if ~cur else value


func to_array():
	var res = []
	for i in range(length):
		res.append(params[i])
		var start = sub_params_idx[i] >> 8
		var end = sub_params_idx[i] & 0xff
		if end - start > 0:
			res.append(sub_params.slice(start, end - 1))
	return res

func reset():
	length = 0
	sub_params_length = 0
	_reject_digits = false
	_reject_sub_digits = false
	digit_is_sub = false
