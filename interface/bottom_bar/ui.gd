extends Control

func _ready() -> void:
	Global.ui_log = $PanelContainer/VBoxContainer/HBoxContainer/ColorRect/Log
	Global.ui_manager.set_ui_node(self)
