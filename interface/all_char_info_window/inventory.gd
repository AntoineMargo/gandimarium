extends Panel

var equipment_labels: Dictionary = {}

func _on_update_inventory_window() -> void:
	var character = Global.selected_char
	for child in Global.items_list.get_children():
		child.queue_free()
	if Global.items_list == null:
		print("ItemsList node not found!")
		return
	if Global.selected_char == null:
		print("No character selected.")
		return
	var items = character.get_inventory()
	for i in range(items.size()):
		var element = preload("res://interface/inventory_element/inventory_element.tscn").instantiate()
		element.items_interface = Enums.ItemsList.INVENTORY
		element.index = i
		element.item = items[i]
		element.initialize()
		Global.items_list.add_child(element)

	for slot in equipment_labels.keys():
		var label_node = equipment_labels[slot]
		if not is_instance_valid(label_node):
			continue

		var item = character.data.equipment.get_item_in_slot(slot)

		label_node.text = item.name if item else "Empty"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.update_inventory.connect(_on_update_inventory_window)
	equipment_labels = {
		Enums.EquipmentSlot.HELM: $"%HelmItem",
		Enums.EquipmentSlot.CAPE: $"%CapeItem",
		Enums.EquipmentSlot.ARMOUR: $"%ArmourItem",
		Enums.EquipmentSlot.TOP: $"%TopItem",
		Enums.EquipmentSlot.BELT: $"%BeltItem",
		Enums.EquipmentSlot.BOTTOM: $"%BottomItem",
		Enums.EquipmentSlot.GAUNTLETS: $"%GauntletsItem",
		Enums.EquipmentSlot.SHOES: $"%ShoesItem",
		Enums.EquipmentSlot.NECKLACE: $"%NecklaceItem",
		Enums.EquipmentSlot.BRACER_LEFT: $"%LeftBracerItem",
		Enums.EquipmentSlot.BRACER_RIGHT: $"%RightBracerItem",
		Enums.EquipmentSlot.HAND_LEFT: $"%LeftWeaponItem",
		Enums.EquipmentSlot.HAND_RIGHT: $"%RightWeaponItem",
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
