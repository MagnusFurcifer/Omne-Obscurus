extends Node

var playernode
var puzzle_0_active = false
var puzzle_1_active = false
var puzzle_0_viewport = false
var puzzle_1_viewport = false
var puzzle_pillar_mouse_poisition = Vector2()
var puzzle_pillar_mouse_global_poisition = Vector2()
var puzzle_mouse_global_poisition = Vector2()
var puzzle_mouse_poisition = Vector2()
var puzzle_pillar_0_mouse_entered = false
var sound_scape
var spooky_set_pieces


func _ready():
	pass 
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"): #This just allows us to quit
		get_tree().quit()

func enter_puzzle(player_pos, camera_ref, viewport_ref):
	playernode.puzzle_or_cutscene_active = true
	playernode.get_node("head/Camera/UI/psx_shader").visible = false
	playernode.velocity = Vector3(0, 0, 0)
	playernode.global_transform.origin = player_pos.global_transform.origin
	playernode.first_person_camera.current = false
	playernode.grab_icon.visible = false
	camera_ref.current = true
	camera_ref.get_node("SpotLight").visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	viewport_ref.gui_disable_input = false
	Input.set_custom_mouse_cursor(load("res://assets/puzzles/controls/cursor_dot.png"))

func exit_puzzle(camera_ref, viewport_ref):
	playernode.puzzle_or_cutscene_active = false
	playernode.get_node("head/Camera/UI/psx_shader").visible = true
	playernode.first_person_camera.current = true
	playernode.grab_icon.visible = true
	camera_ref.current = false
	camera_ref.get_node("SpotLight").visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	viewport_ref.gui_disable_input = true
	Input.set_custom_mouse_cursor(load("res://assets/puzzles/controls/cursor_dot.png"))
