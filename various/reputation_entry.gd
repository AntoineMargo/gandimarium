extends Resource
class_name ReputationEntry

@export var subject: String = ""
@export_range(-100, 100, 1) var value: int = 0
