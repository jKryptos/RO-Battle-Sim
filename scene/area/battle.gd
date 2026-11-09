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
	stop_timers()
	battle_ongoing = false
	
	#Temporary healing after battle, will be replaced with health regen when more stats implemented
	after_battle_healing()
	$EndOfCombatTimer.start()

func _on_fight_button_pressed() -> void:
	start_battle()

#Combat Timers
func _on_player_combat_timer_timeout() -> void:
	var damage_dealt = player.attack()
	update_floating_damage_number(enemy_floating_damage_number, damage_dealt)
	enemy_health.remove_health(damage_dealt)
	update_health_Bar(enemy_health_bar, enemy_health_label, enemy_health)

func _on_enemy_combat_timer_timeout() -> void:
	var damage_dealt = enemy.attack()
	update_floating_damage_number(player_floating_damage_number, damage_dealt)
	player_health.remove_health(damage_dealt)
	update_health_Bar(player_health_bar, player_health_label, player_health)

func _on_end_of_combat_timer_timeout() -> void:
	remove_floating_numbers()
	enemy_health_bar.hide()
	enemy.queue_free()

func _on_player_dead():
	player_dead = true
	end_battle()

func _on_enemy_dead():
	enemy_dead = true
	end_battle()

func after_battle_healing() -> void:
	var health_restored: int = 999
	update_floating_healing_number(player_floating_healing_number, health_restored)
	player_health.add_health(health_restored)
	update_health_Bar(player_health_bar, player_health_label, player_health)

func remove_floating_numbers() -> void:
	enemy_floating_damage_number.text = ""
	enemy_floating_healing_number = ""
	player_floating_damage_number.text = ""
	player_floating_healing_number.text = ""

func start_timers() -> void:
	$PlayerCombatTimer.start()
	$EnemyCombatTimer.start()

func stop_timers() -> void:
	$PlayerCombatTimer.stop()
	$EnemyCombatTimer.stop()

func update_health_Bar(health_bar, health_label, combatant_health) -> void:
	health_label.text = "%d/%d" % [combatant_health.health, combatant_health.max_health]
	health_bar.value = combatant_health.health

func update_floating_damage_number(floating_number, damage) -> void:
	floating_number.text = "-%s" % damage

func update_floating_healing_number(floating_number, healing) -> void:
	floating_number.text = "+%s" % healing
