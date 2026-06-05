extends RefCounted
class_name Context

var id: String = ""
var user: Entity = null
var origin = null

var target = null

var degree: int = 0

var condition: Condition = null
var condition_recipient: Entity = null

var created_items: Array[Item] = []
var created_props: Array[Prop] = []
var created_creatures: Array[Creature] = []

var tile_spawned_on: Vector3i = Vector3i(0, 0, 0)

var info = {}

static func movement(u, o, t) -> Context:
	var context = Context.new()
	context.user = u
	context.origin = o
	context.target = t
	return context
