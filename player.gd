extends Node2D

class_name Player

func attack() -> int:
	return $StatComponent/AttackComponent.calculate_damage()
