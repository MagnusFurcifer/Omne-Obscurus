extends Node2D

var screen_size = Vector2(640, 400)
var rune_array = []

var runes_touching_other_runes = false
var runes_setup = false
var complete = true
var forced_exit_happened = true

func _ready():
	screen_size = get_viewport_rect().size
	$lock_label/AnimationPlayer.play("open")

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().get_parent().puzzle_exit()


func _on_exit_button_pressed():
	print("Exit Event")
	get_parent().get_parent().puzzle_exit()


func _input(event: InputEvent) -> void:
	if get_parent().get_parent().this_puzzle_active:
		if event is InputEventMouse:
			print("puzzle_0.gd: Puzzle input mouse event")
			Globals.puzzle_mouse_poisition = event.position
			Globals.puzzle_mouse_global_poisition = event.global_position
