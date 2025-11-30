extends Button

var concentration = null

#@onready var button_icon = $HBoxContainer/Icon
#@onready var button_label = $HBoxContainer/Label

func setup(data):
	if data:
		self.concentration = data
		#icon.texture = concentration.icon
		#button_label.text = concentration.get_ui_label()
		self.text = concentration.source.name
	else:
		self.text = ""

func _pressed():
	if concentration:
		concentration.cancel()
		self.concentration = null
		self.text = ""
		SignalBus.update_ui_for_char.emit()
