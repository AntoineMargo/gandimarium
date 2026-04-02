extends Context
class_name ActivityContext

var activity: Activity = null

var user_stat: int = 0
var target_stat: int = 0

var user_roll: int = 0
var target_roll: int = 0

var result: int = 0
var degree: int = 0

#var created_conditions: Array[AreaCondition] = []
var created_items: Array[Item] = []

var delayed_calls: Array[Callable] = []
var already_hit = null

var current_spell_rank: int = 0
var concentration: Concentration = null
