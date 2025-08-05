extends Node2D

var parent: Node

func update_hp_bar():
	var current_hp = parent.char_data.current_hp
	var max_hp = parent.char_data.max_hp

	$Control/PositiveHP.min_value = 0
	$Control/PositiveHP.max_value = max_hp
	
	$Control/NegativeHP.min_value = -max_hp
	$Control/NegativeHP.max_value = 0

	if current_hp >= 0:
		$Control/PositiveHP.visible = true
		$Control/NegativeHP.visible = false

		$Control/PositiveHP.value = current_hp
		$Control/NegativeHP.value = 0
	else:
		$Control/PositiveHP.visible = false
		$Control/NegativeHP.visible = true

		$Control/PositiveHP.value = current_hp
		$Control/NegativeHP.value = current_hp

func _ready() -> void:
	parent = get_parent()
