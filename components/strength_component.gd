extends Statistics
class_name StrengthComponent

@export var base_strength: int
var current_strength: int

signal strength_changed(current: int, new: int)
