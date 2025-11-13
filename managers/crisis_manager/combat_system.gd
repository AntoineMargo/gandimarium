extends Node

class_name CombatSystem

const CRITICAL_SUCCESS_THRESHOLD = 10
const SUCCESS_THRESHOLD = 0
const FAILURE_THRESHOLD = -10

var slash = [0, 1, 2, 3]
var pierce = [0, 0, 2, 4]
var crush = [0, 0, 3, 3]
var throw = [0, 0, 2, 4]

#func resolve_activity(user: Node, activity: Activity, target: Node) -> CombatResult:
	#var result = CombatResult.new(user, target, activity)
#
	#var degree = _roll_hostile_activity(user, activity.attacking_aptitude, target, activity.defending_aptitude)
#
	## Apply effects in one place
	#for effect in activity.effects:
		#effect.apply(activity, target, degree)
#
	#result.succeed(0, "Activity resolved successfully.") # optional damage value
	#return result

func _roll_hostile_activity(user: Creature, user_stat: String, target: Creature, target_stat: String):
	var user_roll = randi_range(1, 12) 
	var user_score = user_roll + user.data.get(user_stat)
	var target_roll = randi_range(1, 12)
	var target_score = target_roll + target.data.get(target_stat)
	var contest_result = user_score - target_score
	print("contest_result: ", contest_result)
	var degree_of_success = _determine_degree_success(contest_result)
	print("degree of success: ", degree_of_success)

	return degree_of_success

func _determine_degree_success(number: int):
	if number >= CRITICAL_SUCCESS_THRESHOLD:
		return 3  # Critical success
	elif number >= SUCCESS_THRESHOLD:
		return 2  # Normal success
	elif number >= FAILURE_THRESHOLD:
		return 1  # Failure
	else:
		return 0  # Critical failure
