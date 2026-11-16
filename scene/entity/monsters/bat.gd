extends Enemy


func _ready() -> void:
	special_attacks["drain_life"] = drain_life

#Bat drains 50% of damage as restored health
func drain_life() -> void:
	var damage: int = $StatComponent/AttackComponent.calculate_damage()
	var life: int = roundi(damage / 2.0)
	damage_dealt.emit(damage)
	life_gained.emit(life)

func attack():
	special_attacks["drain_life"].call()
