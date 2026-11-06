extends Node2D
class_name Enemy

@export var monster_name: String

func attack() -> int:
	return $StatComponent/AttackComponent.calculate_damage()
