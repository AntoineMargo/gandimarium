extends AbstractStatEntryContainer
class_name LeveledStatEntryContainer

@export var entries: Array[LevelStepStatEntry] = []

func get_entry(_source, target) -> StatEntry:
	for i in range(entries.size() - 1, -1, -1):
		var step = entries[i]
		if target.data.level >= step.level:
			return step.entry

	return null
