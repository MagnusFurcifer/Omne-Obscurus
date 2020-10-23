extends Node2D

var screen_size = Vector2(640, 400)
var rune_array = []

var complete = false
var forced_exit_happened = false

onready var os = $rune_pad/rune_buttons/os
onready var day = $rune_pad/rune_buttons/day
onready var elk = $rune_pad/rune_buttons/elk

onready var gear = $rune_pad/rune_buttons/gear
onready var thorn = $rune_pad/rune_buttons/thorn
onready var ti = $rune_pad/rune_buttons/ti

onready var yri = $rune_pad/rune_buttons/yri
onready var sun = $rune_pad/rune_buttons/sun
onready var hail = $rune_pad/rune_buttons/hail

var is_rune_hovered = false

var code_1 = null
onready var code_1_answer = thorn.texture_normal
var code_2 = null
onready var code_2_answer = hail.texture_normal
var code_3 = null
onready var code_3_answer = os.texture_normal
var code_4 = null
onready var code_4_answer = gear.texture_normal

func init_puzzle():
	code_1 = null
	code_2 = null
	code_3 = null
	code_4 = null
	$code/code_1/rune.texture = load("res://assets/puzzles/controls/runes/blank.png")
	$code/code_2/rune.texture = load("res://assets/puzzles/controls/runes/blank.png")
	$code/code_3/rune.texture = load("res://assets/puzzles/controls/runes/blank.png")
	$code/code_4/rune.texture = load("res://assets/puzzles/controls/runes/blank.png")

func _ready():
	screen_size = get_viewport_rect().size
	$lock_label/AnimationPlayer.play("closed")
	
	os.connect("mouse_entered", self, '_on_button_hover')
	os.connect("mouse_exited", self, '_on_button_unhover')
	os.connect("pressed", self, '_on_rune_pressed', [os])
	day.connect("mouse_entered", self, '_on_button_hover')
	day.connect("mouse_exited", self, '_on_button_unhover')
	day.connect("pressed", self, '_on_rune_pressed', [day])
	elk.connect("mouse_entered", self, '_on_button_hover')
	elk.connect("mouse_exited", self, '_on_button_unhover')
	elk.connect("pressed", self, '_on_rune_pressed', [elk])
	
	gear.connect("mouse_entered", self, '_on_button_hover')
	gear.connect("mouse_exited", self, '_on_button_unhover')
	gear.connect("pressed", self, '_on_rune_pressed', [gear])
	thorn.connect("mouse_entered", self, '_on_button_hover')
	thorn.connect("mouse_exited", self, '_on_button_unhover')
	thorn.connect("pressed", self, '_on_rune_pressed', [thorn])
	ti.connect("mouse_entered", self, '_on_button_hover')
	ti.connect("mouse_exited", self, '_on_button_unhover')
	ti.connect("pressed", self, '_on_rune_pressed', [ti])
	
	yri.connect("mouse_entered", self, '_on_button_hover')
	yri.connect("mouse_exited", self, '_on_button_unhover')
	yri.connect("pressed", self, '_on_rune_pressed', [yri])
	sun.connect("mouse_entered", self, '_on_button_hover')
	sun.connect("mouse_exited", self, '_on_button_unhover')
	sun.connect("pressed", self, '_on_rune_pressed', [sun])
	hail.connect("mouse_entered", self, '_on_button_hover')
	hail.connect("mouse_exited", self, '_on_button_unhover')
	hail.connect("pressed", self, '_on_rune_pressed', [hail])

func _on_rune_pressed(opt):
	print(str(opt.name))
	if !code_1:
		$code/code_1/rune.texture = opt.texture_normal
		code_1 = true
		pass
	elif !code_2:
		$code/code_2/rune.texture = opt.texture_normal
		code_2 = true
		pass
	elif !code_3:
		$code/code_3/rune.texture = opt.texture_normal
		code_3 = true
		pass
	elif !code_4:
		$code/code_4/rune.texture = opt.texture_normal
		code_4 = true
		check_code()
		pass

func check_code():
	if code_1 and code_2 and code_3 and code_4:
		if $code/code_1/rune.texture == code_1_answer:
			if $code/code_2/rune.texture == code_2_answer:
				if $code/code_3/rune.texture == code_3_answer:
					if $code/code_4/rune.texture == code_4_answer:
						puzzle_complete()
		

func _on_button_hover():
	print("puzzle2d_wall_puzzle_01.gd: Rune button hovered over.")
	if get_parent().get_parent().this_puzzle_active:
		is_rune_hovered = true

func _on_button_unhover():
	print("puzzle2d_wall_puzzle_01.gd: Rune button not hovered over.")
	if get_parent().get_parent().this_puzzle_active:
		is_rune_hovered = false

func _process(delta):
	if get_parent().get_parent().this_puzzle_active:
		if Input.is_action_just_pressed("ui_cancel"):
			get_parent().get_parent().puzzle_exit()
			pass
		if is_rune_hovered:
			#print("wall_puzzle_01_2d.gd: Hand cursor")
			Input.set_custom_mouse_cursor(load("res://assets/puzzles/controls/cursor_hand.png"))
		else:
			#print("wall_puzzle_01_2d.gd: dot cursor")
			Input.set_custom_mouse_cursor(load("res://assets/puzzles/controls/cursor_dot.png"))
		if complete:
			if !$puzzle_complete_particles.emitting:
				if !forced_exit_happened:
					forced_exit_happened = true
					print("Forced exit is a bout toahppen")
					get_parent().get_parent().puzzle_exit()

func puzzle_complete():
	if !complete:
		Globals.playernode.get_node("gameplay_sounds/magical_sound").play()
		Globals.playernode.queue_message("That did the trick.", 1.5, load("res://assets/VO/that_did_the_trick.wav"))
		complete = true
		$lock_label/AnimationPlayer.play("open")
		get_parent().get_parent().get_parent().get_parent().get_node("area_03_door").unlock_door()
		$puzzle_complete_particles.emitting = true
		$back_button.visible = false

func _on_back_button_pressed():
	print("wall_puzzle_01_2d.gd: Back Event")
	if !complete:
		init_puzzle()

func _input(event: InputEvent) -> void:
	if get_parent().get_parent().this_puzzle_active:
		if event is InputEventMouse:
			#print("wall_puzzle_01_2d.gd" + str(event.position))
			pass



func _on_out_btn_pressed():
	print("wall_puzzle_01_2d.gd: Exit Event")
	get_parent().get_parent().puzzle_exit()
