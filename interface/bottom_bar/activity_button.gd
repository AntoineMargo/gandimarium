extends TextureButton
class_name ActivityButton

@export var activity: Activity

func _on_pressed():
	modulate = Color(0.6, 0.6, 0.6)

func _on_released():
	modulate = Color(1, 1, 1)

func _ready():
	button_down.connect(_on_pressed)
	button_up.connect(_on_released)
