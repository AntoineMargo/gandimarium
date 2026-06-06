extends Resource
class_name ShaderEffect

@export var parameter_name: String
@export var value: Variant
@export var blend_mode: int = 0
# 0 = override
# 1 = max
# 2 = add

@export var pulse: PulseProfile = null
