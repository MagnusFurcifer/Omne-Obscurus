extends KinematicBody

#Movement Vars
export var speed : float = 5 #5 is the default speed
export var acceleration : float = 3
export var couch_modifier : float = 0.5
export var movement_friction : float = 20
export var gravity : float = -40
export var maximum_slope_angle : float = 60
export var bouancy : float = 0.05

export var lantern_range_ext = 26
export var lantern_range_int = 15

#Camera Vars
export(float, 0.1, 1) var mouse_sens = 0.3
export(float, -90, 0) var min_pitch = -90
export(float, 0, 90) var max_pitch = 90

#Movement Tracking
var velocity : Vector3 = Vector3()
var camera_x_rotation = 0
var y_velocity : float
var slope_contact = false
const max_slope_angle = 80
var is_crouching  = false
var flashlight_enabled = false
var is_moving = false
var in_water = false
var lantern_out = false


#Access to nodes
onready var head = $head
onready var first_person_camera = $head/Camera
onready var grab_icon = $head/Camera/UI/center_indicators/grab_icon
onready var look_icon = $head/Camera/UI/center_indicators/look_icon


var message_queue = []

var puzzle_or_cutscene_active = false
var looking_at_note = false
var note_ref = null


export var player_debug_msgs = false


#Fadein
var stage1 = false
var stage2 = false
var stage3 = false

var footsteps_grass = [
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_1.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_2.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_3.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_4.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_5.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_6.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_7.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_8.wav"),
	load("res://assets/sounds/world/effects/footsteps/Grass/Grass_Footstep_9.wav")
]

var footsteps_wood = [
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_1.wav"),
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_2.wav"),
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_3.wav"),
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_4.wav"),
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_5.wav"),
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_6.wav"),
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_7.wav"),
	load("res://assets/sounds/world/effects/footsteps/Wood/Wood_Footstep_8.wav")
]
var footsteps_stone = [
	load("res://assets/sounds/world/effects/footsteps/Stone/Stone_Footstep_1.wav"),
	load("res://assets/sounds/world/effects/footsteps/Stone/Stone_Footstep_2.wav"),
	load("res://assets/sounds/world/effects/footsteps/Stone/Stone_Footstep_3.wav"),
	load("res://assets/sounds/world/effects/footsteps/Stone/Stone_Footstep_4.wav"),
	load("res://assets/sounds/world/effects/footsteps/Stone/Stone_Footstep_5.wav"),
	load("res://assets/sounds/world/effects/footsteps/Stone/Stone_Footstep_6.wav"),
	load("res://assets/sounds/world/effects/footsteps/Stone/Stone_Footstep_7.wav")
]

var footsteps_blood = [
	load("res://assets/sounds/world/effects/footsteps/blood/walk_01.wav"),
	load("res://assets/sounds/world/effects/footsteps/blood/walk_02.wav")
]

var in_blood = false

func switch_lantern_range():
	if $head/Camera/lantern/player_lantern.spot_range == lantern_range_ext:
		$head/Camera/lantern/player_lantern.spot_range = lantern_range_int
	else:
		$head/Camera/lantern/player_lantern.spot_range = lantern_range_ext

func process_footsteps():
	get_tree().get_nodes_in_group("floor_wood")
	var ground_type = "grass"
	$CollisionShape/slope_ray.force_raycast_update()
	if $CollisionShape/slope_ray.is_colliding():
		if player_debug_msgs: print("player.gd: Specific footstep material: " + str($CollisionShape/slope_ray.get_collider().name))
		if $CollisionShape/slope_ray.get_collider().is_in_group("floor_wood"):
			ground_type = "wood"
		if $CollisionShape/slope_ray.get_collider().is_in_group("floor_stone"):
			ground_type = "stone"
		if $CollisionShape/slope_ray.get_collider().is_in_group("floor_grass"):
			ground_type = "grass"
		if in_blood:
			ground_type = "blood"
			
	for obj in get_tree().get_nodes_in_group("floor_grass"): #This is a fix for rugs whgich are small and anoying
		if obj.overlaps_body(self):
			if player_debug_msgs: print("player.gd: Overlap detected with area: " + str(obj.name))
			ground_type = "grass"
	if is_moving and !in_water and $gameplay_sounds/foot_steps/footstep_delay.time_left == 0:
		if player_debug_msgs: print("player.gd:  Processing foot steps because characer is moving and not in water")
		var footstep_player = $gameplay_sounds/foot_steps
		var foot_sound
		if ground_type == "grass":
			foot_sound = footsteps_grass[randi() % footsteps_grass.size()]
		elif ground_type == "stone":
			foot_sound = footsteps_stone[randi() % footsteps_stone.size()]
		elif ground_type == "wood":
			foot_sound = footsteps_wood[randi() % footsteps_wood.size()]
		elif ground_type == "blood":
			foot_sound = footsteps_blood[randi() % footsteps_blood.size()]
		footstep_player.stream = foot_sound
		footstep_player.play()
		$gameplay_sounds/foot_steps/footstep_delay.start()

func _ready():
	Globals.playernode = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup_ui()
	
	#Kick off the fade_in
	puzzle_or_cutscene_active = true
	$head/Camera/UI/instructions.visible = false
	$head/Camera/UI/black_fade_in_intro/AnimationPlayer.play("location_show")

func _on_fadein_intro_animation_finished(anim_name):
	if anim_name == "location_show":
		$head/Camera/UI/black_fade_in_intro/stage1.start()
	elif anim_name == "date_show":
		$head/Camera/UI/black_fade_in_intro/stage2.start()
	elif anim_name == "text_disappear":
		$head/Camera/UI/black_fade_in_intro/stage3.start()
	elif anim_name == "background_fade_in":
		puzzle_or_cutscene_active = false
		$head/Camera/UI/instructions.visible = true
		Globals.playernode.queue_message("It's dark. Luckily I bought my lantern.", 5, load("res://assets/VO/dark_I bought_lantern.wav"))
		$head/Camera/UI/instructions/AnimationPlayer.play("show_instructions")
		$head/Camera/UI/black_fade_in_intro.queue_free()

func _on_stage1_timeout():
	$head/Camera/UI/black_fade_in_intro/AnimationPlayer.play("date_show")
func _on_stage2_timeout():
	$head/Camera/UI/black_fade_in_intro/AnimationPlayer.play("text_disappear")
func _on_stage3_timeout():
	$head/Camera/UI/black_fade_in_intro/AnimationPlayer.play("background_fade_in")

func hide_ui():
	$head/Camera/UI/instructions/AnimationPlayer.play("hide_instructions")

func process_msg_queue():
	var msg_current = false #This is true if there is an active message
	for msg in message_queue:
		if msg["active"]:
			if msg["timer"].is_stopped():
				msg["msg_label"].visible = false
				message_queue.erase(msg)
				msg["msg_label"].queue_free()
			else:
				msg_current = true
	if !msg_current: #If there is no current message, we can pop and create
		if message_queue.size() > 0:
			message_queue[0]["msg_label"].visible = true
			$head/Camera/UI/messages.add_child(message_queue[0]["msg_label"])
			$head/Camera/UI/messages.add_child(message_queue[0]["timer"])
			if message_queue[0]["wav"] != null:
				$voice.stream = message_queue[0]["wav"]
				$voice.play()
			message_queue[0]["timer"].start()
			message_queue[0]["active"] = true

func queue_message(msg_text, timeout, wav=null):
	var msg_label = Label.new()
	msg_label.text = msg_text
	msg_label.add_font_override("font", load("res://entities/fonts/messages_font.tres"))
	var msg_timer = Timer.new()
	msg_timer.wait_time = timeout
	msg_timer.one_shot = true
	var message_dict = {
		"msg_label" : msg_label,
		"timer" : msg_timer,
		"active" : false,
		"wav" : wav
	}
	message_queue.append(message_dict)



func process_debug_panel():
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_0_active/Label.text = str(Globals.puzzle_0_active)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_1_active/Label.text = str(Globals.puzzle_1_active)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_0_viewport/Label.text = str(Globals.puzzle_0_viewport)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_1_viewport/Label.text = str(Globals.puzzle_1_viewport)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_pillar_mouse/Label.text = str(Globals.puzzle_pillar_mouse_poisition)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_pillar_mouse_global/Label.text = str(Globals.puzzle_pillar_mouse_global_poisition)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_mouse/Label.text = str(Globals.puzzle_mouse_poisition)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_mouse_global/Label.text = str(Globals.puzzle_mouse_global_poisition)
	$head/Camera/UI/debug/puzzle_debug_panel/puzzle_pillar_0_entered/Label.text = str(Globals.puzzle_pillar_0_mouse_entered)
	
	
func setup_ui():
	grab_icon.visible = false
	look_icon.visible = false



func pick_up_note(note_obj):
	velocity = Vector3(0, 0, 0)
	puzzle_or_cutscene_active = true
	looking_at_note = true
	note_ref = load(note_obj.note_ui).instance()
	$head/Camera/UI/note_node.add_child(note_ref)



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "bring_out_lantern":
		if !lantern_out:
			lantern_out = true
	elif anim_name == "put_away_lantern":
		if lantern_out:
			lantern_out = false

func shutdown_lights():
	$head/Camera/lantern.visible = false
	
func _process(delta):
	process_debug_panel()
	process_msg_queue()
	
	if !puzzle_or_cutscene_active:
		if Input.is_action_just_pressed("ui_fullscreen"):
			OS.window_fullscreen = !OS.window_fullscreen
		if Input.is_action_just_pressed("action_flashlight"):
			flashlight_enabled = !flashlight_enabled

	if flashlight_enabled and !puzzle_or_cutscene_active:
		if !lantern_out && !$head/Camera/AnimationPlayer.is_playing():
			$head/Camera/AnimationPlayer.play("bring_out_lantern")
			$gameplay_sounds/open_bag.play()
		for obj in get_tree().get_nodes_in_group("shadow_objects"):
			if $head/Camera/flashlight/flash_light_visible_area.overlaps_body(obj):
				obj.in_flashlight()
	else:
		if lantern_out && !$head/Camera/AnimationPlayer.is_playing():
			$head/Camera/AnimationPlayer.play("put_away_lantern")
			$gameplay_sounds/open_bag.play()
	
	if !looking_at_note:
		if $head/Camera/use_ray.is_colliding():
			var use_collider = $head/Camera/use_ray.get_collider()
			grab_icon.visible = false
			look_icon.visible = false
			
			if use_collider != null:
				if use_collider.is_in_group("usable_object") and !puzzle_or_cutscene_active:
					grab_icon.visible = true
					if Input.is_action_just_pressed("action_use"):
						print("WE DID IT")
						use_collider.use()
				if use_collider.is_in_group("lookable_object") and !puzzle_or_cutscene_active:
					look_icon.visible = true
					if Input.is_action_just_pressed("action_look"):
							print("WE LOOKED AT IT")
							use_collider.look()
		else:
			grab_icon.visible = false
			look_icon.visible = false
	else:
		grab_icon.visible = false
		look_icon.visible = false
		if Input.is_action_just_pressed("action_use") or Input.is_action_just_pressed("action_look"):
			$head/Camera/UI/note_node.remove_child(note_ref)
			puzzle_or_cutscene_active = false
			looking_at_note = false


func _input(ev):
	if ev is InputEventMouseMotion and !puzzle_or_cutscene_active:
		rotate_y(deg2rad(-ev.relative.x * mouse_sens)) #If the mouse moves, we rotate the head around the y axis based on the x axis movement of the mouse (ie side movement makes the head actually roates around the vertical line)
		rotate_camera(ev)

func rotate_camera(ev):
	var x_delta = ev.relative.y * mouse_sens
	first_person_camera.rotate_x(deg2rad(-x_delta)) #Mose go verticcal, camera rotate up and down (Lateral axis)
	first_person_camera.rotation.x = clamp(first_person_camera.rotation.x, deg2rad(-90), deg2rad(90))

func _physics_process(delta):

	var head_basis = head.get_global_transform().basis #Direction that the head is facing. 
	var direction = Vector3() #Empty vector that will hold our direction after processing
	if !puzzle_or_cutscene_active:
		is_moving = false
		if Input.is_action_pressed("move_forward"):
			direction -= head_basis.z #Direction is toward the direction the head is facing
			is_moving = true
		elif Input.is_action_pressed("move_backward"):
			direction += head_basis.z #Direction is ttoward the direction the head is facing
			is_moving = true
		if Input.is_action_pressed("move_left"):
			direction -= head_basis.x #Move perpenticulalry to the direction the head is facing
			is_moving = true
		elif Input.is_action_pressed("move_right"):
			direction += head_basis.x #Move perpenticulalry to the direction the head is facing
			is_moving = true
		###Crouch Implementation
		if Input.is_action_pressed("move_crouch"):
			self.scale.y = 0.5
			is_crouching = true
		else:
			self.scale.y = 1
			is_crouching = false
	#Lateral Direction and Speed
	var tmp_speed = speed
	if is_crouching: 
		tmp_speed = speed * couch_modifier 
	#Gravity and Swimming
	in_water = false
	for water_body in get_tree().get_nodes_in_group("water"):
		if water_body.overlaps_area($bouancy_area):
			if velocity.y < 0:
				velocity.y = 0
			in_water = true
	#GROUND CONTACT CHECKING
	if is_on_floor(): 
		#print("On Floor")
		slope_contact = true
		var n = $CollisionShape/slope_ray.get_collision_normal()
		var floor_angle = rad2deg(acos(n.dot(Vector3(0, 1, 0))))
		if floor_angle > max_slope_angle:
			#print("Greater than max angle, applying gravity")
			velocity.y += gravity * delta
	else:
		if !$CollisionShape/slope_ray.is_colliding():
			slope_contact = false
			if !in_water:
				#print("Not on floor, and not in water")
				velocity.y += gravity * delta
	#WATER SWIMMING
	if in_water:
		velocity.y += bouancy
	if slope_contact and !is_on_floor() and !in_water: 
		move_and_collide(Vector3(0, -1, 0))
	#Applying speed and dir tro velocity
	direction.y = 0 
	var direction_normalized = direction.normalized() 
	velocity = velocity.linear_interpolate(direction_normalized * tmp_speed, acceleration * delta) 
	#APply Movement
	velocity = move_and_slide(velocity, Vector3.UP, 0.20)
	
	#Footsteps are played if moving and stuff
	process_footsteps()

#Kill all velocty when we hit the water
func _on_ocean_area_entered(area):
	if area == $bouancy_area:
		if velocity.y < -3:
			print("Killing y velocity")
			velocity.y = 0


func _on_flashlight_area_entered(body):
	if body.is_in_group("shadow_objects"):
		if flashlight_enabled:
			body.in_flashlight()


func _on_flashlight_area_exited(body):
	if body.is_in_group("shadow_objects"):
		if flashlight_enabled:
			body.in_darkness()
