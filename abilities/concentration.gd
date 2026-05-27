extends Resource
class_name Concentration

@export var linked_conditions: Array[Condition] = []

var source = null
var start_time: int
var PP_consumed: int = 0

func setup(src, drain: bool = false):
	source = src
	start_time = Global.time_manager.get_total_seconds()
	
	if drain:
		if not SignalBus.time_changed.is_connected(tick_tock):
			SignalBus.time_changed.connect(tick_tock)

func finalize_setup():
	for condition in linked_conditions:
		if not condition.ended.is_connected(cancel):
			condition.ended.connect(cancel)
		#if not condition.update_info.is_connected(update_info):
			#condition.update_info.connect(update_info)

func update_info(info):
	pass

func tick_tock(_days, _hours, _minutes, _seconds):
	var current_time: int = Global.time_manager.get_total_seconds()
	@warning_ignore("integer_division")
	var elapsed_rounds: int = (current_time - start_time) / 6
	
	var rounds_to_charge = elapsed_rounds - PP_consumed
	if rounds_to_charge <= 0:
		return

	for i in range(rounds_to_charge):
		if not source.user.consume_pp(1):
			cancel()
			return
		PP_consumed += 1
		SignalBus.update_ui_for_char.emit()

func register_condition(condition: Condition):
	if not linked_conditions.has(condition):
		linked_conditions.append(condition)

func cancel():
	if SignalBus.time_changed.is_connected(tick_tock):
		SignalBus.time_changed.disconnect(tick_tock)
	for condition in linked_conditions:
		if is_instance_valid(condition):
			if condition.ended.is_connected(cancel):
				condition.ended.disconnect(cancel)
			condition.remove_source(source.id)
	linked_conditions.clear()
	if source and source.user and source.user.data.concentrations.has(self):
		source.user.remove_concentration(self)
	SignalBus.update_ui_for_char.emit()
