extends Node2D

var screen_size = Vector2(640, 400)
var rune_array = []

var runes_touching_other_runes = false
var runes_setup = false
var complete = false
var forced_exit_happened = false
var inside_paper = false

func _ready():
	screen_size = get_viewport_rect().size
	$lock_label/AnimationPlayer.play("closed")
	for node in get_children():
		if node.is_in_group("rune"):
			rune_array.append(node)
			runes_setup = true

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().get_parent().puzzle_exit()
	if get_parent().get_parent().this_puzzle_active:
		if runes_setup:
			raycast_to_each_rune()
		
func raycast_to_each_rune():
	runes_touching_other_runes = false
	if !complete:
		for rune in rune_array:
			#print("Checking all runes")
			for target_rune in rune_array:
				#print("Against all otehr runes")
				if rune != target_rune:
					#print("Make sure the targer rune and the rune are not he same")
					var rune_ray = rune.get_node("RayCast2D")
					rune_ray.rotation = get_angle_to(target_rune.global_position)
					rune_ray.force_raycast_update()
					if rune_ray.is_colliding():
						#print("Rune is collidng")
						var target_collider = rune_ray.get_collider()
						#print(str(target_collider))
						if target_collider.is_in_group("rune"):
							#print("Found collision with another rune")
							if rune_ray.get_collider().rune_type != rune.rune_type:
								#print("Rune Types Match")
								runes_touching_other_runes = true
		#If nothing is touching another rune then we complete the puzzle
	if !runes_touching_other_runes:
		print("PUZZLE COMPLETE")
		puzzle_complete()
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
		get_parent().get_parent().get_parent().get_parent().get_node("door").unlock_door()
		$puzzle_complete_particles.emitting = true
		$back_button.visible = false

func _on_exit_button_pressed():
	print("Exit Event")
	get_parent().get_parent().puzzle_exit()

func _on_back_button_pressed():
	if !complete:
		$puzzle_line.reset()

func _input(event: InputEvent) -> void:
	if get_parent().get_parent().this_puzzle_active:
		if event is InputEventMouse:
			#print("Puzzle01.gd" + str(event.position))
			pass


func _on_paper_mouse_entered():
	print("Paper Entered")
	inside_paper = true


func _on_paper_mouse_exited():
	print("Paper Existed")
	inside_paper = false
