extends CanvasModulate

@export var red_curve: Curve
@export var green_curve: Curve
@export var blue_curve: Curve


func update_light(hour: int):
	var t: float = float(hour) / 24.0

	var r = red_curve.sample(t)
	var g = green_curve.sample(t)
	var b = blue_curve.sample(t)

	color = Color(r, g, b)

func _ready() -> void:
	SignalBus.hour_change.connect(update_light)
