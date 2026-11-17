extends Resource
class_name ItemContainer

@export var item: Item = null
@export var amount: int = 1

@export_storage var owner_uid: int = 0

var owner = null # Resource? Vector3i for Props?

@export_storage var uid: int = 0

func _init(p_item: Item = null, p_amount: int = 1) -> void:
	item = p_item
	amount = p_amount


func get_uid() -> int:
	return uid


func can_stack_with(other_item: Item) -> bool:
	if item == null or other_item == null:
		return false
	return item.id == other_item.id


func can_stack_with_container(other_container: ItemContainer) -> bool:
	if other_container == null or other_container.item == null:
		return false
	if uid != 0 or other_container.uid != 0:
		return false
	return can_stack_with(other_container.item)


func is_empty() -> bool:
	return item == null or amount <= 0


func add(add_amount: int = 1) -> void:
	amount += add_amount


func remove(remove_amount: int = 1) -> int:
	var actual: int = mini(remove_amount, amount)
	amount -= actual
	return actual


func duplicate_container(split_amount: int = -1) -> ItemContainer:
	var count_to_copy: int = amount if split_amount < 0 else split_amount
	return ItemContainer.new(item, count_to_copy)


func split(split_amount: int) -> ItemContainer:
	var actual_amount: int = mini(split_amount, amount)
	amount -= actual_amount
	return ItemContainer.new(item, actual_amount)

func destroy():
	if owner_uid:
		owner = Global.state_manager.get_creature_by_uid(owner_uid)
	if owner and owner.has_method("remove_item_container"):
		owner.remove_item_container(self)
