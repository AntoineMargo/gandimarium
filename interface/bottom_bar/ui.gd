extends Control

func _ready() -> void:
	Global.ui_log = $PanelContainer/VBoxContainer/HBoxContainer/TextEdit
	Global.ui_manager.set_ui_node(self)
