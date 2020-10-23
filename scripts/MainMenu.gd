extends Control

func _ready():
	pass # Replace with function body.

func _on_exit_game_pressed():
	get_tree().quit()

func _on_start_game_pressed():
	get_tree().change_scene("res://scenes/story_preamble.tscn")
