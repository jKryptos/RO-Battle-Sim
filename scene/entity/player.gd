extends Node2D

class_name Player

signal damage_dealt(damage: int)
signal life_gained(life: int)

func attack() -> void:
	damage_dealt.emit($StatComponent/AttackComponent.calculate_damage())
