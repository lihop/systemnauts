extends MarginContainer


func notify(message):
	var notification = Label.new()
	notification.text = message
	
	# Show the notification for 3 seconds.
	$NotificationArea.add_child(notification)
	yield(get_tree().create_timer(3), "timeout")
	$NotificationArea.remove_child(notification)
