extends Enemy

#Bat drains 50% of damage as restored health
func attack() -> int:
	var damage: int = $StatComponent/AttackComponent.calculate_damage()
	var life_leeched: int = roundi(damage * .7)
	$StatComponent/HealthComponent.add_health(life_leeched)
	return damage
