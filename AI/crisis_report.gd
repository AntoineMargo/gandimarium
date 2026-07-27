extends RefCounted
class_name CrisisReport

var closest_enemy: Creature = null
var strongest_enemy: Creature = null
var most_vulnerable_enemy: Creature = null

var closest_ally: Creature = null
var most_vulnerable_ally: Creature = null

var enemy_positions: Dictionary[Creature, Vector3i] = {}

var turn: TurnReport = null
