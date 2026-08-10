extends RefCounted
class_name TurnReport

var starting_ap: int = 0
var starting_pp: int = 0
var starting_ep: int = 0
var starting_mp: int = 0

var starting_position: Vector3i

var total_ap_used: int = 0

var chosen_method: HTNMethod = null

var method_is_valid: bool = false
