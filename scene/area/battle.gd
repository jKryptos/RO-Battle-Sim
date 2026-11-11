extends Node2D

#Player nodes
var player_health
@onready var player_spawn = $Combatants/PlayerBox/PlayerSpawn
@onready var player_health_bar = $Combatants/PlayerBox/PlayerHealth
@onready var player_health_label = $Combatants/PlayerBox/PlayerHealth/Label
@onready var player_floating_damage_number = $DamageNumbers/HBoxContainer/PlayerDamageNumber
@onready var player_floating_healing_number = $HealingNumbers/HBoxContainer/PlayerHealingNumber

#Enemy nodes
var enemy_health
@onready var enemy_spawn = $Combatants/EnemyBox/EnemySpawn
@onready var enemy_health_bar = $Combatants/EnemyBox/EnemyHealth
@onready var enemy_health_label = $Combatants/EnemyBox/EnemyHealth/Label
@onready var enemy_floating_damage_number = $DamageNumbers/HBoxContainer/EnemyDamageNumber
@onready var enemy_floating_healing_number = $HealingNumbers/HBoxContainer/EnemyHealingNumber

#Combat variables
var player
var enemy
var battle_ongoing: bool
var player_dead: bool
var enemy_dead: bool

var enemies = [
		preload("res://Scene/Entity/Monsters/Bat/bat.tscn"),
		preload("res://Scene/Entity/Monsters/Skeleton/skeleton.tscn"),
		preload("res://Scene/Entity/Monsters/Goblin/goblin.tscn")
]

func _ready() -> void:
	spawn_player()
	spawn_enemy()

func spawn_enemy() -> void:
	enemy = enemies.pick_random().instantiate()
	enemy_health = enemy.get_node("StatComponent/HealthComponent")
	enemy_health.dead.connect(_on_enemy_dead)
	enemy_spawn.add_child(enemy)
	enemy_dead = false
	enemy_health_bar.show()
	enemy_health_bar.max_value = enemy_health.max_health
	enemy_health_bar.value = enemy_health.health
	enemy_health_label.text = "%d/%d" % [enemy_health.health, enemy_health.max_health]

func spawn_player() -> void:
	player = preload("res://Scene/Entity/player.tscn").instantiate()
	player_health = player.get_node("StatComponent/HealthComponent")
	player_health.dead.connect(_on_player_dead)
	player_spawn.add_child(player)
	player_health_bar.max_value = player_health.max_health
	player_health_bar.value = player_health.health
	player_health_label.text = "%d/%d" % [player_health.health, player_health.max_health]

func start_battle() -> void:
	if battle_ongoing == true or player_dead == true:
		return

	if enemy_dead == true:
		spawn_enemy()

	start_timers()
	battle_ongoing = true

func end_battle() -> void:
	battle_ongoing = false
	stop_timers()
	#Temporary healing after battle, will be replaced with health regen when more stats implemented
	after_battle_healing()

func _on_fight_button_pressed() -> void:
	start_battle()

func _on_player_combat_timer_timeout() -> void:
	var damage_dealt = player.attack()
	do_attack(enemy_health_bar, enemy_health_label, enemy_health, enemy_floating_damage_number, damage_dealt, enemy)

func _on_enemy_combat_timer_timeout() -> void:
	var damage_dealt = enemy.attack()
	do_attack(player_health_bar, player_health_label, player_health, player_floating_damage_number, damage_dealt, player)

func _on_player_dead():
	player_dead = true
	end_battle()

func _on_enemy_dead():
	enemy_dead = true
	enemy_health_bar.hide()
	enemy.queue_free()
	end_battle()

func after_battle_healing() -> void:
	var health_restored: int = 999
	do_heal(player_health_bar, player_health_label, player_health, player_floating_healing_number, health_restored, player)

func start_timers() -> void:
	$PlayerCombatTimer.start()
	$EnemyCombatTimer.start()

func stop_timers() -> void:
	$PlayerCombatTimer.stop()
	$EnemyCombatTimer.stop()

func update_health_Bar(health_bar, health_label, combatant_health) -> void:
	health_label.text = "%d/%d" % [combatant_health.health, combatant_health.max_health]
	health_bar.value = combatant_health.health

func move_floating_number_up(number) -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.set_ease(tween.EASE_OUT)
	tween.tween_property(number, "modulate:a", 0.0, 1.5)
	tween.tween_property(number, "position:y", number.position.y - 50, 1.5)
	tween.chain().tween_callback(number.queue_free)

func new_floating_damage_number(number: Label, amount: int, target: Node2D) -> Label:
	var new_number: Label = number.duplicate()
	new_number.text = "-%s" % amount

	$DamageNumbers/FloatingNumber.add_child(new_number)
	new_number.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	new_number.global_position = target.global_position + Vector2(randi_range(-10, 10), -300)
	new_number.modulate.a = 1.0
	new_number.show()

	return new_number

func new_floating_healing_number(number: Label, amount: int, target: Node2D) -> Label:
	var new_number: Label = number.duplicate()
	new_number.text = "+%s" % amount

	$HealingNumbers/FloatingNumber.add_child(new_number)
	new_number.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	new_number.global_position = target.global_position + Vector2(0, -150)
	new_number.modulate.a = 1.0
	new_number.show()

	return new_number

func do_attack(health_bar, health_label, health, floating_number, damage, target) -> void:
	move_floating_number_up(new_floating_damage_number(floating_number, damage, target))
	health.remove_health(damage)
	update_health_Bar(health_bar, health_label, health)

func do_heal(health_bar, health_label, health, floating_number, heal, target) -> void:
	move_floating_number_up(new_floating_healing_number(floating_number, heal, target))
	health.add_health(heal)
	update_health_Bar(health_bar, health_label, health)
