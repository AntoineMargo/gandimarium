extends TextureButton
class_name ActivityButton

@export var activity: Activity

func _ready():
	custom_minimum_size = Vector2(40, 40)
	if activity:
		$ActivityRect.texture = load(activity.icon)
