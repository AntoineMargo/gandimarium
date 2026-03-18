extends Panel

var root = null

@onready var line_edit = $HBoxContainer/VBoxContainer/HBoxContainer/LineEdit

func _on_name_entered(new_text: String) -> void:
	print("Final name:", new_text)
	root.data.name = new_text

func _ready() -> void:
	root = $"../../../.."
	line_edit.text_submitted.connect(_on_name_entered)
	
