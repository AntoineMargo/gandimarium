extends Panel

var root = null

enum Attribute {
	ACUITY,
	BRAWN,
	DEXTERITY,
	RESOLVE
}

@onready var acuity_spinbox = $VBoxContainer/HBoxContainer/VBoxContainer/Acuity/SpinBox
@onready var brawn_spinbox = $VBoxContainer/HBoxContainer/VBoxContainer/Brawn/SpinBox
@onready var dexterity_spinbox = $VBoxContainer/HBoxContainer/VBoxContainer/Dexterity/SpinBox
@onready var resolve_spinbox = $VBoxContainer/HBoxContainer/VBoxContainer/Resolve/SpinBox

@onready var points_left = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/PointsLeft

var extra_budget_at_start: int = 4
var budget_left: int = 0

var acuity_delta: float = 0
var brawn_delta: float = 0
var dexterity_delta: float = 0
var resolve_delta: float = 0

func value_changed(_attribute: Attribute) -> void:
	acuity_delta = acuity_spinbox.value - 6
	brawn_delta = brawn_spinbox.value - 6
	dexterity_delta = dexterity_spinbox.value - 6
	resolve_delta = resolve_spinbox.value - 6
	
	@warning_ignore("narrowing_conversion")
	budget_left = extra_budget_at_start - acuity_delta - brawn_delta - dexterity_delta - resolve_delta
	points_left.text = "%d" % [budget_left]

	if budget_left >= 0:
		modify_creature_attributes()
		root.skills.initialise()

func modify_creature_attributes():
	var attributes = root.data.attributes
	attributes.acuity = acuity_spinbox.value
	attributes.brawn = brawn_spinbox.value
	attributes.dexterity = dexterity_spinbox.value
	attributes.resolve = resolve_spinbox.value

func _on_acuity_value_changed(_value: float) -> void:
	value_changed(Attribute.ACUITY)

func _on_brawn_value_changed(_value: float) -> void:
	value_changed(Attribute.BRAWN)

func _on_dexterity_value_changed(_value: float) -> void:
	value_changed(Attribute.DEXTERITY)
	
func _on_resolve_value_changed(_value: float) -> void:
	value_changed(Attribute.RESOLVE)

func _ready() -> void:
	root = $"../../../.."
	budget_left = extra_budget_at_start
	points_left.text = "%d" % [budget_left]
	acuity_spinbox.value_changed.connect(_on_acuity_value_changed)
	brawn_spinbox.value_changed.connect(_on_brawn_value_changed)
	dexterity_spinbox.value_changed.connect(_on_dexterity_value_changed)
	resolve_spinbox.value_changed.connect(_on_resolve_value_changed)
	
