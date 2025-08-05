extends Camera2D

@export var zoomSpeed : float = 10
@export var panSpeed : float = 10

var zoomTarget : Vector2
var panTarget : Vector2

func _ready() -> void:
	zoomTarget = zoom
	pass

func _process(delta: float) -> void:
	Zoom(delta)
	SimplePan(delta)
	ClickAndDrag()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if get_viewport().gui_get_hovered_control():
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					zoomTarget *= 1.1
				MOUSE_BUTTON_WHEEL_DOWN:
					zoomTarget *= 0.9

func Zoom(delta):
	# var mouse_pos_before  = get_global_mouse_position()
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)
	# var mouse_pos_after  = get_global_mouse_position()
	# position += mouse_pos_before - mouse_pos_after

func SimplePan(delta):
	panTarget = Vector2.ZERO

	var speed_multiplier = 2 if Input.is_action_pressed("Shift") else 1

	if Input.is_action_pressed("camera_move_up"):
		panTarget.y -= 1
	if Input.is_action_pressed("camera_move_down"):
		panTarget.y += 1
	if Input.is_action_pressed("camera_move_right"):
		panTarget.x += 1
	if Input.is_action_pressed("camera_move_left"):
		panTarget.x -= 1

	panTarget = panTarget.normalized()
	position += panTarget * panSpeed * speed_multiplier * delta * 100 * (1/zoom.x)

func ClickAndDrag():
	pass
