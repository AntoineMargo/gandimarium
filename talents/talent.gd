extends Resource
class_name Talent

@export var name: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String
@export var filters: Array[Filter] = []
@export var effects: Array[Effect] = []
@export var supplanted: Array[Talent] = []
@export var re_apply_effects: bool = false

#func initialize(target) -> void:
	#for effect in effects:
		#apply_context(ctx)
		##effect.apply(self, target, -1)

func initialize(target) -> void:
	for effect in effects:
		var ctx = Context.new()
		ctx.user = target
		ctx.origin = target.get_coords()
		ctx.target = target
		if effect.has_method("apply_context"):
			effect.apply_context(ctx)
		else:
			effect.apply(self, ctx.target)
