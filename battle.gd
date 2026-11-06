extends Node2D

#Player nodes
var player_health
@onready var player_spawn = $Combatants/PlayerBox/PlayerSpawn
@onready var player_health_bar = $Combatants/PlayerBox/PlayerHealth
@onready var player_health_label = $Combatants/PlayerBox/PlayerHealth/Label

#Enemy nodes
var enemy_health
@onready var enemy_spawn = $Combatants/EnemyBox/EnemySpawn
@onready var enemy_health_bar = $Combatants/EnemyBox/EnemyHealth
@onready var enemy_health_label = $Combatants/EnemyBox/EnemyHealth/Label

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

	$PlayerCombatTimer.start()
	$EnemyCombatTimer.start()
	battle_ongoing = true

func end_battle() -> void:
	$PlayerCombatTimer.stop()
	$EnemyCombatTimer.stop()
	battle_ongoing = false
	player_health.add_health(200)
	player_health_label.text = "%d/%d" % [player_health.health, player_health.max_health]
	player_health_bar.value = player_health.health

func _on_fight_button_pressed() -> void:
	start_battle()

#Combat Timers
func _on_player_combat_timer_timeout() -> void:
	enemy_health.remove_health(player.attack())
	enemy_health_bar.value = enemy_health.health
	enemy_health_label.text = "%d/%d" % [enemy_health.health, enemy_health.max_health]

func _on_enemy_combat_timer_timeout() -> void:
	player_health.remove_health(enemy.attack())
	player_health_bar.value = player_health.health
	player_health_label.text = "%d/%d" % [player_health.health, player_health.max_health]

func _on_player_dead():
	player_dead = true
	end_battle()

func _on_enemy_dead():
	enemy_dead = true
	enemy_health_bar.hide()
	enemy.queue_free()
	end_battle()
