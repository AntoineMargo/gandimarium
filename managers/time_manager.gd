extends Node
class_name TimeManager

var seconds: int = 0
var minutes: int = 0
var hours: int = 11
var days: int = 0

var world_timer: Timer = Timer.new() 

func _on_world_timeout():
	advance_time()

func _on_crisis_mode_started(_creature):
	world_timer.paused = true

func _on_crisis_mode_ended(_creature):
	world_timer.paused = false

func advance_time():
	seconds += 1

	if seconds >= 60:
		seconds = 0
		minutes += 1

	if minutes >= 60:
		minutes = 0
		hours += 1
		SignalBus.hour_change.emit(hours)

	if hours >= 24:
		hours = 0
		days += 1

	SignalBus.time_changed.emit(hours, minutes, seconds)

func _ready() -> void:
	add_child(world_timer)
	world_timer.wait_time = 1.0
	#world_timer.autostart = true
	world_timer.start()
	world_timer.timeout.connect(_on_world_timeout)
	SignalBus.start_crisis_mode.connect(_on_crisis_mode_started)
	SignalBus.end_crisis_mode.connect(_on_crisis_mode_ended)
