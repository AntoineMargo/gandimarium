extends Resource
class_name ItemContainer

@export var item: Item = null
@export var amount: int = 1


func _init(p_item: Item = null, p_amount: int = 1) -> void:
	item = p_item
	amount = p_amount


func can_stack_with(other_item: Item) -> bool:
	if item == null or other_item == null:
		return false
	if item.uid != 0 or other_item.uid != 0:
		return false
	return item.id == other_item.id


func can_stack_with_container(other_container: ItemContainer) -> bool:
	if other_container == null or other_container.item == null:
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
