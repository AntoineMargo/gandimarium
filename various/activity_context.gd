extends Context
class_name ActivityContext

var activity: Activity = null

var user_stat: int = 0
var target_stat: int = 0

var user_roll: int = 0
var target_roll: int = 0

var result: int = 0
var degree: int = 0

var created_items: Array[Item] = []

var current_spell_rank: int = 0
var concentration: Concentration = null
