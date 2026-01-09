extends Node
class_name IDManager

var _next_id: int = 1

func next_id() -> int:
	var id := _next_id
	_next_id += 1
	return id
