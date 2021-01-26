class_name Phone
extends SmartObject

var alerting := false


func _on_SIPClient_CallIncoming():
	alerting = true
	$Ring.play()


func _on_SIPClient_CallCancelled():
	alerting = false
	$Ring.stop()
