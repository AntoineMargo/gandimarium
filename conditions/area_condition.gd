extends Condition
class_name AreaCondition

@export var applied_condition: Condition
@export var trigger: Enums.AreaConditionTrigger

var uid: int
var linked_conditions: Array = []
var affected_tiles: Array[Vector3i] = []
var affected_entities: Dictionary[Entity, Condition] = {} # Node, bool
#var affected_entities: Dictionary[int, bool] = {} # UID, bool

var is_finalized: bool = false

func initialize(ctx: Context) -> void:
	self.user = ctx.user
	if user is Creature:
		self.user_uid = user.data.uid
	ctx.condition = self
	if ctx is ActivityContext:
		self.spell_rank = ctx.current_spell_rank
		if ctx.concentration:
			ctx.concentration.register_condition(self)
	start_time = Global.time_manager.get_total_seconds()
	if duration > 0:
		end_time = start_time + duration
		SignalBus.time_changed.connect(verify_expired)

func finalize():
	if is_finalized:
		return

	is_finalized = true
	
	if affected_tiles.is_empty():
		return

	if vfx_scene:
		vfx_instance = vfx_scene.instantiate()
		vfx_instance.setup(self)

		Global.add_child(vfx_instance)
		Global.world_manager.VFX_scenes.append(vfx_instance)

func register_linked_condition(condition: Condition):
	if not linked_conditions.has(condition):
		linked_conditions.append(condition)

func cancel_linked_conditions():
	for condition in linked_conditions:
		if is_instance_valid(condition):
			#condition.dispose()
			condition.remove_source(self.id)
	linked_conditions.clear()

func apply_to_entity(entity):
	if affected_entities.has(entity):
		return

	var ctx = Context.new()
	ctx.user = self.user
	ctx.target = entity
	ctx.condition = applied_condition

	if not ctx.target.has_condition(applied_condition.id):
		ctx.target.toggle_condition(ctx)

	if entity is Creature:
		affected_entities[entity] = applied_condition
		#affected_entities[entity.data.uid] = true

func remove_from_entity(entity):
	if not affected_entities.has(entity):
		return

	var condition = affected_entities[entity]
	
	var ctx = Context.new()
	ctx.user = self.user
	ctx.target = entity
	ctx.condition = applied_condition
	if ctx.target.has_condition(condition.id):
		ctx.target.toggle_condition(ctx)
	
	affected_entities.erase(entity)

func clear_tiles():
	var wm = Global.world_manager
	for tile in affected_tiles:
		var layer_tile = Vector2i(tile.x, tile.y)
		for element in wm.layers[tile.z]["contents"][layer_tile]:
			if element == self:
				wm.layers[tile.z]["contents"][layer_tile].erase(element)
				break

func dispose():
	destroy_children()
	cancel_linked_conditions()
	clear_tiles()
	for entity in affected_entities.keys():
		remove_from_entity(entity)
	affected_entities.clear()
	vfx_instance.queue_free()
	if Global.selected_char == target:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
