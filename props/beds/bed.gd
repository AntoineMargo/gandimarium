extends Prop
class_name Bed

@export var condition: Condition

func _build_context(target = null):
	var ctx = Context.new()
	ctx.id = id
	ctx.user = self
	ctx.origin = self
	ctx.target = target
	ctx.condition = condition
	ctx.tile_spawned_on = target.get_coords()
	return ctx

func apply_context(ctx: Context) -> void:
	ctx.target.toggle_condition(ctx)

func operate(creature: Creature):
	#if creature.feels_safe():
	var ctx = _build_context(creature)
	ctx.target.toggle_condition(ctx)
	if Global.selected_char == creature:
		SignalBus.dialog_show_message.emit("You start sleeping")
		Global.time_manager.skip_time(0, 8)

func _ready() -> void:
	id = "bed"
	condition = Library.get_condition("bed_sleep")
	_on_ready()
