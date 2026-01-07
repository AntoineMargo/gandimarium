extends Resource
class_name AffiliationEntry

enum Role {
	NONE,
	MEMBER,
	ALLY,
	LEADER
}

@export var faction: String = ""
@export var role: Role = Role.MEMBER
#@export var is_member: bool = false
