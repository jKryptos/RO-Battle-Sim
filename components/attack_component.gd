extends Statistics
class_name AttackComponent

@export var base_attack_power: int
@export var strength_component: StrengthComponent

var current_attack_power: int

signal attack_changed(current: int, new: int)

func _ready():
	calculate_current_attack_power()

func calculate_current_attack_power():
	current_attack_power = base_attack_power + strength_component.current_strength

func calculate_damage() -> int:
	return roundi(current_attack_power * randf_range(0.7, 1.5))
