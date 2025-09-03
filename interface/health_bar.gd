extends Node2D

var parent: Node

func update_hp_bar():
	var current_hp = parent.data.current_hp
	var max_hp = parent.data.max_hp

	$PositiveHP.min_value = 0
	$PositiveHP.max_value = max_hp
	
	$NegativeHP.min_value = -max_hp
	$NegativeHP.max_value = 0

	if current_hp >= 0:
		$PositiveHP.visible = true
		$NegativeHP.visible = false

		$PositiveHP.value = current_hp
		$NegativeHP.value = 0
	else:
		$PositiveHP.visible = false
		$NegativeHP.visible = true

		$PositiveHP.value = current_hp
		$NegativeHP.value = current_hp

func _ready() -> void:
	parent = get_parent()
