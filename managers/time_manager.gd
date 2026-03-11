extends Node
class_name TimeManager

var seconds: int = 0
var minutes: int = 0
var hours: int = 8
var days: int = 0

var world_timer: Timer = Timer.new() 

func _on_world_timeout():
	advance_time()

func _on_crisis_mode_started(_creature):
	world_timer.paused = true

func _on_crisis_mode_ended(_creature):
	world_timer.paused = false

func advance_time():
	seconds += 6

	if seconds >= 60:
		seconds = 0
		minutes += 1

	if minutes >= 60:
		minutes = 0
		hours += 1
		#SignalBus.hour_change.emit(hours)

	if hours >= 24:
		hours = 0
		days += 1

	SignalBus.time_changed.emit(days, hours, minutes, seconds)

func skip_time(skipped_days: int, skipped_hours: int = 0, skipped_minutes: int = 0, skipped_seconds: int = 0):
	var old_total_hours = days * 24 + hours

	var total_seconds = seconds
	total_seconds += minutes * 60
	total_seconds += hours * 3600
	total_seconds += days * 86400

	total_seconds += skipped_seconds
	total_seconds += skipped_minutes * 60
	total_seconds += skipped_hours * 3600
	total_seconds += skipped_days * 86400

	@warning_ignore("integer_division")
	days = total_seconds / 86400
	var remainder = total_seconds % 86400

	@warning_ignore("integer_division")
	hours = remainder / 3600
	remainder = remainder % 3600

	@warning_ignore("integer_division")
	minutes = remainder / 60
	seconds = remainder % 60

	var new_total_hours = days * 24 + hours
	var hour_difference = new_total_hours - old_total_hours

	SignalBus.time_skipped.emit(hour_difference)
	SignalBus.time_changed.emit(days, hours, minutes, seconds)

func jump_to_time(new_days: int, new_hours: int, new_minutes: int, new_seconds: int):
	var hour_difference = ((new_days - days) * 24) + (new_hours - hours)
	
	if hour_difference <= 0:
		return
	
	days = new_days
	hours = new_hours
	minutes = new_minutes
	seconds = new_seconds

	SignalBus.time_skipped.emit(hour_difference)
	SignalBus.time_changed.emit(days, hours, minutes, seconds)

func get_total_seconds() -> int:
	return seconds + minutes * 60 + hours * 3600 + days * 86400

#func skip_time(skipped_days: int, skipped_hours: int = 0, skipped_minutes: int = 0, skipped_seconds: int = 0):
	#var old_hours = hours
	#var old_days = days
	#
	#seconds += skipped_seconds
	#minutes += skipped_minutes
	#hours += skipped_hours
	#days += skipped_days
#
	#@warning_ignore("integer_division")
	#minutes += seconds / 60
	#seconds = seconds % 60
#
	#@warning_ignore("integer_division")
	#hours += minutes / 60
	#minutes = minutes % 60
#
	#@warning_ignore("integer_division")
	#days += hours / 24
	#hours = hours % 24
#
	#@warning_ignore("integer_division")
	#var hour_difference = ((days - old_days) * 24) + (hours - old_hours)
	#
	#for hour in range(hour_difference):
		#SignalBus.hour_change.emit(hours)
#
	#SignalBus.time_skipped.emit(hour_difference)
	#SignalBus.time_changed.emit(days, hours, minutes, seconds)

func _ready() -> void:
	add_child(world_timer)
	world_timer.wait_time = 1.0
	#world_timer.autostart = true
	world_timer.start()
	world_timer.timeout.connect(_on_world_timeout)
	SignalBus.start_crisis_mode.connect(_on_crisis_mode_started)
	SignalBus.end_crisis_mode.connect(_on_crisis_mode_ended)
