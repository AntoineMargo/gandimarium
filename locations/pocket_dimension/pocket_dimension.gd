extends Map
class_name Dimension

var portal_location: Vector3i = Vector3i(0, 0, 0)

func find_ejection_spots(destination: Vector3i, amount: int) -> Array[Vector3i]:
	var result: Array[Vector3i] = []

	if amount <= 0:
		return result

	var pos: Vector3i = destination
	var direction: Vector3i = Vector3i.RIGHT
	var steps: int = 1

	while result.size() < amount:
		for _i in range(2):
			for _j in range(steps):
				pos += direction

				if not Global.world_manager.get_entity_at_pos(pos):
					result.append(pos)

					if result.size() >= amount:
						return result

			direction = Vector3i(-direction.y, direction.x, direction.z)

		steps += 1

	return result

func destroy_self() -> void:
	var spots: Array[Vector3i] = find_ejection_spots(portal_location, creatures.size())
	for i in range(creatures.size() - 1, -1, -1):
		Global.world_manager.teleport(creatures[i], spots[i])
