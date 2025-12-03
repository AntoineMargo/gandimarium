extends Resource

class_name Personality

# Inclinations
@export_range(1, 100) var caution = 50 # reckless to paranoid
@export_range(1, 100) var sociality = 50 # solitary to communal
@export_range(1, 100) var compassion = 50 # cruel to compassionate
@export_range(1, 100) var dedication = 50 # wavering to iron-willed

# Faculties
@export_range(1, 100) var intelligence = 50 # incompetent to hyper-competent
@export_range(1, 100) var charisma = 50 # unpleasant to captivating

# Aspirations
@export_range(1, 100) var ambition = 25 # content to power-hungry

# Dynamic state
@export_range(1, 100) var morale = 50 # dynamic, used and changed in crisis situations
