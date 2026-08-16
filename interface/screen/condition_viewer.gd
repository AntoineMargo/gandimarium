extends CanvasLayer

@onready var container = $Control/HBoxContainer

var condition_square = preload("res://interface/screen/condition_square.tscn")

func build_condition_squares() -> void:
	for child in container.get_children():
		child.queue_free()
	
	var character = Global.selected_char
	if not character:
		return
	
	for condition in character.data.conditions:
		if condition.is_visible:
			var new_square = condition_square.instantiate()
			var text: String = condition.name + "\n" + condition.description
			new_square.tooltip_text = text
			if condition.icon:
				new_square.texture = load(condition.icon)
			else:
				print("Using paceholder for condition square.")
				new_square.texture = load("res://art/interface/activities/placeholder1.png")
			container.add_child(new_square)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.update_ui_for_char.connect(build_condition_squares)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
