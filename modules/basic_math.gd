class_name BasicMath

const CRITICAL_SUCCESS_THRESHOLD = 10
const SUCCESS_THRESHOLD = 0
const FAILURE_THRESHOLD = -10

static func noise():
	pass

## straight check
static func make_regular_check(stat: int, roll: int) -> int:
	return  stat + roll

## comparison between two creatures' checks
static func make_opposed_check(stat1: int, roll1: int, stat2: int, roll2: int) -> int:
	var result1 = stat1 + roll1
	var result2 = stat2 + roll2
	var contest_result = result1 - result2

	return contest_result

static func determine_degree_success(contest_result: int) -> int:
	if contest_result >= CRITICAL_SUCCESS_THRESHOLD:
		return 3  # Critical success
	elif contest_result >= SUCCESS_THRESHOLD:
		return 2  # Normal success
	elif contest_result >= FAILURE_THRESHOLD:
		return 1  # Failure
	else:
		return 0  # Critical failure

static func determine_damage(dice_number: int, damage_die: int, damage_bonus: int, degree_success: int,damage_pattern: DamagePattern = null) -> int:
	if not damage_pattern:
		damage_pattern = Library.get_dmg_pattern("default")
	
	var total_damage: int = 0
	if damage_pattern.pattern[degree_success] == 0:
		return (0)
	dice_number *= damage_pattern.pattern[degree_success]
	for die in range(dice_number):
		total_damage += randi_range(1, damage_die)
	total_damage += damage_bonus
	return (total_damage)

static func standard_roll() -> int: # also called daring roll
	return randi_range(1, 12)

static func guarded_roll() -> int:
	return randi_range(1, 6) + randi_range(1, 6)

static func safe_roll() -> int:
	return 6 + randi_range(1, 6)

static func average_roll() -> int:
	return 6
