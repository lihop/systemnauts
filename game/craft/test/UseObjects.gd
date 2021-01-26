extends AIBehavior


func add_options(context):
	for object in context.objects.keys():
		if object is SmartObject:
			context.params = {
				object = object, object_state = context.objects[object], stats = context.stats
			}
			object.add_options(context)
