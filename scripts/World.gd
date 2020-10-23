extends Spatial

var day = false
onready var start_area_terrain = load("res://entities/world/terrain/starting_area_terrain.tscn")
onready var bowl_terrain = load("res://entities/world/terrain/bowl_terrain.tscn")

func _ready():
	$area_01.add_child(start_area_terrain.instance())
	$final_area.add_child(bowl_terrain.instance())
	Globals.sound_scape = $sound_scape
	Globals.spooky_set_pieces = $spooky_set_pieces
	process_time()

func day():
	$WorldEnvironment.environment = load("res://environments/day.tres")

func night():
	$WorldEnvironment.environment = load("res://environments/night.tres")

func process_time():
	if day:
		day()
	else:
		night()

func update_debug_stuff():
	if Globals.playernode:
		Globals.playernode.get_node("head/Camera/UI/debug/light_debug_panel/current_world_energy/Label").text = str($WorldEnvironment.environment.background_energy)

func _process(delta):
	
	update_debug_stuff()
	
	if Globals.playernode:
		if !Globals.playernode.puzzle_or_cutscene_active:
			if Input.is_action_just_pressed("ui_timechange"):
				day = !day
			
	if Globals.playernode:
		if Input.is_action_just_pressed("debug_teleport"):
			Globals.playernode.global_transform.origin = $debug_spawn.global_transform.origin
		if Input.is_action_just_pressed("debug_speed_change"):
			if Globals.playernode.speed == 5:
				Globals.playernode.speed = 25
			else:
				Globals.playernode.speed = 5
	
	if Input.is_action_just_pressed("option_brightness_down"):
		$WorldEnvironment.environment.background_energy = $WorldEnvironment.environment.background_energy - .1
		pass
	elif Input.is_action_just_pressed("option_brightness_up"):
		$WorldEnvironment.environment.background_energy = $WorldEnvironment.environment.background_energy + .1
		pass
	
	process_time()
	if !day:
		var rotate_vector = Vector3(0, -1, 0)
		$WorldEnvironment.environment.background_sky_rotation_degrees += rotate_vector * delta
	


var flicker_action = false
func _on_flicking_light_body_entered(body):
	if body == Globals.playernode and !flicker_action:
		$area_02/first_room/objects/lights/light_animation_player.play("room_1_light_flicker")
		$area_02/first_room/objects/lights/ceiling_light/hanging_lantern/flicking_light.queue_free()
		$area_02/first_room/objects/lights/ceiling_light/hanging_lantern/bzz.play()
		flicker_action = true
