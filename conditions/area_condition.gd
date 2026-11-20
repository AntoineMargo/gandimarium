extends Condition
class_name AreaCondition

@export var applied_condition: Condition
@export var trigger: Enums.AreaConditionTrigger
@export var area_follows_target: bool = false

@export_storage var uid: int
@export_storage var affected_tiles: Array[Vector3i] = []
@export_storage var linked_conditions: Array = []
@export_storage var affected_entities_uids_to_conditions: Dictionary[int, Condition] = {}
#@export_storage var affected_entities: Dictionary = {} # Entity/Creature -> Condition
#@export_storage var affected_entities_uids: Dictionary[int, bool] = {} # UID, bool

@export_storage var is_finalized: bool = false

@export_storage var area_spread: int = 0
@export_storage var area_LOS: bool = false

var affected_entities: Array[Entity] = []


func get_references_from_uids() -> void:
	if affected_entities.is_empty():
		for entity_uid in affected_entities_uids_to_conditions.keys():
			affected_entities.append(Global.state_manager.get_creature_by_uid(entity_uid))


func re_setup() -> void:
	get_references_from_uids()
	apply_vfx()
	setup_signals()
	SignalBus.event.connect(handle_area_exit)


func initialize(ctx: Context) -> void:
	print("INITIALIZE: ", get_instance_id(), " UID: ", uid)
	self.user = ctx.user
	if user is Creature:
		self.user_uid = user.data.uid
	self.target = ctx.target
	ctx.condition = self
	if ctx is ActivityContext:
		self.spell_rank = ctx.spell_rank
		if ctx.concentration:
			ctx.concentration.register_condition(self)

		if area_follows_target:
			area_spread = ctx.activity.spread
			area_LOS = ctx.activity.spread_requires_LOS
			target.data.following_area_conditions.append(self)

	start_time = Global.time_manager.get_total_seconds()
	if duration > 0:
		end_time = start_time + duration
		SignalBus.time_changed.connect(handle_time)
	SignalBus.event.connect(handle_area_exit)

	get_references_from_uids()


func apply_vfx() -> void:
	clear_vfx()
	
	if vfx_scenes.is_empty():
		return

	for vfx_scene in vfx_scenes:
		var vfx = vfx_scene.instantiate()
		vfx.setup(self)

		Global.game_session.add_child(vfx)
		#Global.world_manager.VFX_scenes.append(vfx)
		vfx_instances.append(vfx)



func finalize():
	if is_finalized:
		return

	is_finalized = true
	
	if affected_tiles.is_empty():
		return

	apply_vfx()


func register_linked_condition(condition: Condition):
	if not linked_conditions.has(condition):
		linked_conditions.append(condition)


#func cancel_linked_conditions():
	#for condition in linked_conditions:
		#if is_instance_valid(condition):
			##condition.dispose()
			#condition.remove_source(self.id)
	#linked_conditions.clear()


func apply_to_entity(entity: Entity):
	#var entity_uid: int = entity.get_uid()
	#var saved_uid: int = affected_entities_uids.get(entity_uid)
	#if saved_uid:
		#return

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
			linked_conditions.append(instance)
			instance.freeze()
			
			affected_entities.append(entity)
			var entity_uid: int = entity.get_uid()
			affected_entities_uids_to_conditions[entity_uid] = instance
			print("APPLY")
			print("AreaCondition instance: ", get_instance_id())
			print("AreaCondition UID: ", uid)
			print("Dictionary: ", affected_entities_uids_to_conditions)


func remove_from_entity(entity):
	if not affected_entities.has(entity):
		return
	
	var ctx = Context.new()
	ctx.user = self.user
	ctx.target = entity
	ctx.condition = applied_condition
	if ctx.target.has_condition(applied_condition.id):
		ctx.target.toggle_condition(ctx)
	
	affected_entities.erase(entity)
	var entity_uid: int = entity.get_uid()
	affected_entities_uids_to_conditions.erase(entity_uid)


func handle_area_exit(reaction_event: ReactionEvent):
	var event_entity: Entity = reaction_event.context.user
	if affected_entities.has(event_entity):
		var pos = event_entity.get_coords()
		if pos not in affected_tiles:
			if applied_condition.duration == -1:
				remove_from_entity(event_entity)
			else:
				var entity_uid: int = event_entity.get_uid()
				affected_entities_uids_to_conditions[entity_uid].unfreeze()
	
	# The event entity is in control of this area condition
	if area_follows_target and target == event_entity: 
		for entity in affected_entities:
			var entity_pos: Vector3i = entity.get_coords()
			if entity_pos not in affected_tiles:
				if applied_condition.duration == -1:
					remove_from_entity(entity)
				else:
					var entity_uid: int = entity.get_uid()
					affected_entities_uids_to_conditions[entity_uid].unfreeze()


func clear_tiles():
	var wm = Global.world_manager
	for i in range(affected_tiles.size() - 1, -1, -1):
		var tile = affected_tiles[i]
		var layer_tile = Vector2i(tile.x, tile.y)
		for element in wm.layers[tile.z]["contents"][layer_tile]:
			if element is AreaCondition and element.id == self.id:
				wm.layers[tile.z]["contents"][layer_tile].erase(element)
				break
		affected_tiles.remove_at(i)


func move_area(reaction_event: ReactionEvent) -> void:
	#var old_pos: Vector3i = reaction_event.context.origin
	var new_pos: Vector3i = reaction_event.context.target
	var new_tiles: Array[Vector3i] = WorldMath.get_burst_tiles(new_pos, area_spread, area_LOS)
	clear_tiles()
	for tile in new_tiles:
		add_tile(tile)


func add_tile(pos: Vector3i) -> void:
	print("ADD TILE: ", get_instance_id(), " UID: ", uid)
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
	print("DISPOSE")
	print("AreaCondition instance: ", get_instance_id())
	print("AreaCondition UID: ", uid)
	print("Dictionary: ", affected_entities_uids_to_conditions)
	destroy_children()
	clear_vfx()
	#cancel_linked_conditions()
	clear_tiles()
	for entity in affected_entities:
		remove_from_entity(entity)
	affected_entities.clear()
	if area_follows_target:
		target.data.following_area_conditions.erase(self)
