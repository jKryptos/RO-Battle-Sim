extends Node

var player_level: int = 1 
var player_XP: int = 0
var player_XP_required_for_levelup: int = 100
var player_XP_current_level: int = 0

var player_gold_in_hand: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calculate_XP_requirement() -> int:
	return 100 * pow(1.07, player_level + 1)

func player_level_up():
	while player_XP_current_level >= player_XP_required_for_levelup:
		player_XP_current_level -= player_XP_required_for_levelup
		player_level += 1
		player_XP_required_for_levelup = calculate_XP_requirement()
