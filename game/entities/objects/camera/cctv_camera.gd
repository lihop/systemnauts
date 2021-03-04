extends Spatial

onready var viewport: Viewport = $Viewport
onready var timestamp: Label = $Viewport/Timestamp


func take_photo() -> Image:
	# Get timestamp code by jospic and volzhs from https://godotengine.org/qa/19077/how-to-get-the-date-as-per-rfc-1123-date-format-in-game?show=19111
	var time = OS.get_datetime()
	var nameweekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var namemonth = [
		"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	]
	var dayofweek = time["weekday"]
	var day = time["day"]
	var month = time["month"]
	var year = time["year"]
	var hour = time["hour"]
	var minute = time["minute"]
	var second = time["second"]
	var dateRFC1123 = (
		"%s, %02d %s %d %02d:%02d:%02d GMT"
		% [nameweekday[dayofweek], day, namemonth[month - 1], year, hour, minute, second]
	)

	timestamp.text = "%s %s" % [name, dateRFC1123]
	var image: Image = viewport.get_texture().get_data()
	image.flip_y()
	return image
