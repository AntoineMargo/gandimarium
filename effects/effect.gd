extends Resource
class_name Effect

@export var required_degree: int = 0

func sufficient_degree(ctx: Context) -> bool:
	if ctx.degree >= required_degree:
		return true
	else:
		return false

func apply(_source, _target, _degree: int = 2) -> void:
	pass

#func apply_context(context) -> bool:
	#pass

#func apply_context(ctx: Context) -> bool:
	#if not sufficient_degree(ctx):
		#return false
	#return true
