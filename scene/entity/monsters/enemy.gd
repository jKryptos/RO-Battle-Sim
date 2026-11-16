extends Node2D
class_name Enemy

@export var monster_name: String

signal damage_dealt(damage: int)
signal life_gained(life: int)

var special_attacks: Dictionary = {}

func attack() -> void:
	damage_dealt.emit($StatComponent/AttackComponent.calculate_damage())
