extends Control

@onready var nodes = {
	"grid" =  $PanelContainer/VBoxContainer/HBoxContainer/Activities,
	"crisis_mode" = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/CrisisModeButton,
	"end_turn" = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/EndTurnButton,
	"set_toggler" = $PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/CheckButton,
	"weapon1" = $PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/Weapon1,
	"weapon2" = $PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/Weapon2
}

# zzz

func _ready() -> void:
	Global.ui_log = $PanelContainer/VBoxContainer/HBoxContainer/ColorRect/Log
	Global.ui_manager.set_ui_node(self)
	print("here it be!")
	print(nodes["grid"])
