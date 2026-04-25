extends TextureButton
class_name ActivityButton

@export var activity: Activity

func _ready():
	if activity:
		$ActivityRect.texture = load(activity.icon)
