extends CanvasLayer

var time_label = null

func change_time(_days, hours, minutes, _seconds):
	var first_part = "%02d" % hours
	var second_part = "%02d" % minutes
	time_label.text = "%s:%s" % [first_part, second_part]

func _ready() -> void:
	time_label = $Control/ColorRect/Time
	SignalBus.time_changed.connect(change_time)
