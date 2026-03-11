extends CanvasModulate

@export var red_curve: Curve
@export var green_curve: Curve
@export var blue_curve: Curve

@export var current_hours: int = -1
@export var current_minutes: int = -1


func update_light(_days: int, hours: int, minutes: int, _seconds: int):
	if hours == current_hours and minutes == current_minutes:
		return
	current_hours = hours
	current_minutes = minutes

	var t: float = (hours + minutes / 60.0) / 24.0
	#var t: float = float(hours) / 24.0

	var r = red_curve.sample(t)
	var g = green_curve.sample(t)
	var b = blue_curve.sample(t)

	color = Color(r, g, b)

func _ready() -> void:
	SignalBus.time_changed.connect(update_light)
	#SignalBus.hour_change.connect(update_light)
