class_name AIParams
extends Reference

var _missing_params := PoolStringArray()


func _init(context: AIDecisionContext):
	for param in context.params:
		if param in self:
			set(param, context.params[param])

	for property in self.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE != 0 and get(property.name) == null:
			_missing_params.append(property.name)


func get_missing_params() -> PoolStringArray:
	return _missing_params
