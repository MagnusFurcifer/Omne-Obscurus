extends Node2D

var screen_size = Vector2(640, 400)


func _ready():
	screen_size = get_viewport_rect().size


func puzzle_complete():
	get_parent().get_parent().get_parent().get_parent().get_node("door").unlock_door()

func _on_exit_button_pressed():
	print("Exit Event")
	puzzle_complete()
	get_parent().get_parent().puzzle_exit()

func _on_back_button_pressed():
	print("Back Event")
	pass

func _input(event: InputEvent) -> void:
	pass
