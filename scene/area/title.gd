extends Node2D


func _on_start_button_pressed() -> void:
	ScreenTransition.change_scene("res://Scene/Area/battle.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
