extends CanvasLayer
class_name ContainerWindow

var current_container: ContainerProp = null

func _on_update_container(container_prop: ContainerProp = current_container) -> void:
	if container_prop:
		current_container = container_prop
	if not current_container:
		return
	if Global.container_list == null:
		print("ItemsList node not found!")
		return

	for child in Global.container_list.get_children():
		child.queue_free()

	var items = container_prop.runtime_inventory
	for i in range(items.size()):
		var element = preload("res://interface/inventory_window/inventory_element.tscn").instantiate()
		element.items_interface = Enums.ItemsInterface.CONTAINER
		element.index = i
		element.item = items[i]
		element.initialize()
		Global.container_list.add_child(element)

func _on_exit_pressed() -> void:
	Global.container_window.visible = false

func _ready() -> void:
	SignalBus.update_container.connect(_on_update_container)
	$Control/ColorRect/VBoxContainer/TopBar/StatusBar/ExitButton.pressed.connect(_on_exit_pressed)
