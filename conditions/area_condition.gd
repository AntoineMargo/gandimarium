extends Condition
class_name AreaCondition

@export var applied_condition: Condition
@export var trigger: Enums.AreaConditionTrigger
@export var area_follows_target: bool = false

var uid: int
var linked_conditions: Array = []
var affected_tiles: Array[Vector3i] = []
var affected_entities: Dictionary[Entity, Condition] = {} # Node, Condition
#var affected_entities: Dictionary[int, bool] = {} # UID, bool

var is_finalized: bool = false

var area_spread: int = 0
var area_LOS: bool = false


func initialize(ctx: Context) -> void:
	self.user = ctx.user
	if user is Creature:
		self.user_uid = user.data.uid
	self.target = ctx.target
	ctx.condition = self
	if ctx is ActivityContext:
		self.spell_rank = ctx.current_spell_rank
		if ctx.concentration:
			ctx.concentration.register_condition(self)

		if area_follows_target:
			area_spread = ctx.activity.spread
			area_LOS = ctx.activity.spread_requires_LOS
			target.data.following_area_conditions.append(self)

	start_time = Global.time_manager.get_total_seconds()
	if duration > 0:
		end_time = start_time + duration
		SignalBus.time_changed.connect(verify_expired)
	SignalBus.event.connect(handle_area_exit)


func finalize():
	if is_finalized:
		return

	is_finalized = true
	
	if affected_tiles.is_empty():
		return

	if vfx_scenes.is_empty():
		return
		
	for vfx_scene in vfx_scenes:
		var vfx = vfx_scene.instantiate()
		vfx.setup(self)

		Global.add_child(vfx)
		#Global.world_manager.VFX_scenes.append(vfx)
		vfx_instances.append(vfx)


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

	if entity is Creature:
		var instance: Condition
		if not ctx.target.has_condition(applied_condition.id):
			instance = ctx.target.toggle_condition(ctx)
			affected_entities[entity] = instance
			#affected_entities[entity.data.uid] = true
			instance.freeze()


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


func handle_area_exit(reaction_event: ReactionEvent):
	var entity = reaction_event.context.user
	if affected_entities.has(entity):
		var pos = entity.get_coords()
		if pos not in affected_tiles:
			if applied_condition.duration == -1:
				remove_from_entity(entity)
			else:
				affected_entities[entity].unfreeze()


func clear_tiles():
	var wm = Global.world_manager
	for tile in affected_tiles:
		var layer_tile = Vector2i(tile.x, tile.y)
		for element in wm.layers[tile.z]["contents"][layer_tile]:
			if element == self:
				wm.layers[tile.z]["contents"][layer_tile].erase(element)
				break


func move_area(reaction_event: ReactionEvent) -> void:
	#var old_pos: Vector3i = reaction_event.context.origin
	var new_pos: Vector3i = reaction_event.context.target
	var new_tiles: Array[Vector3i] = WorldMath.get_burst_tiles(new_pos, area_spread, area_LOS)
	clear_tiles()
	for tile in new_tiles:
		add_tile(tile)


func add_tile(pos: Vector3i) -> void:
	var wm = Global.world_manager
	var layer_pos = Vector2i(pos.x, pos.y)
	if not wm.layers[pos.z]["contents"].has(layer_pos):
		wm.layers[pos.z]["contents"][layer_pos] = []
	wm.layers[pos.z]["contents"][layer_pos].append(self)

	affected_tiles.append(pos)
	var entity_on_tile = wm.get_entity_at_pos(pos)
	wm.handle_tile_conditions(pos, entity_on_tile)


#func remove_tile(pos: Vector3i) -> void:
	#var wm = Global.world_manager
	#var layer_pos = Vector2i(pos.x, pos.y)
	#for element in wm.layers[pos.z]["contents"][layer_pos]:
		#if element == self:
			#wm.layers[pos.z]["contents"][layer_pos].erase(element)
			#break


func dispose():
	destroy_children()
	clear_vfx()
	cancel_linked_conditions()
	clear_tiles()
	for entity in affected_entities.keys():
		remove_from_entity(entity)
	affected_entities.clear()
	if area_follows_target:
		target.data.following_area_conditions.erase(self)
	if Global.selected_char == target:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
