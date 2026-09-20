extends CanvasLayer
class_name PromptWindow

signal finished(result: Dictionary)

@onready var done_button = $Control/ColorRect/VBoxContainer/HBoxContainer/Button

var user: Creature = null

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
@onready var control = get_node_or_null("%Control")
@onready var top_bar = get_node_or_null("%TopBar")
@onready var exit_button = get_node_or_null("%ExitButton")

@onready var list = get_node_or_null("%List")

func setup(u: Creature) -> void:
	user = u

func _cleanup() -> void:
	user = null

func _on_exit_pressed() -> void:
	$".".visible = false
	_cleanup()
	finished.emit([])

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if visible:
					if control.get_global_rect().has_point(get_viewport().get_mouse_position()):
						Global.set_active_window(self)
					
					if top_bar.get_global_rect().has_point(get_viewport().get_mouse_position()):
						dragging = true
						drag_offset = get_viewport().get_mouse_position() - control.global_position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		control.global_position = get_viewport().get_mouse_position() - drag_offset


func finish() -> void:
	_cleanup()
	finished.emit({})


func _ready() -> void:
	layer = 200
	control.z_index = 200
	exit_button.pressed.connect(_on_exit_pressed)
	done_button.pressed.connect(finish)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
