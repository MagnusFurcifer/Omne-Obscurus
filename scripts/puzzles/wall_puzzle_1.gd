extends Spatial



var this_puzzle_active = false

# The size of the quad mesh itself.
var quad_mesh_size
# Used for checking if the mouse is inside the Area
var is_mouse_inside = false
# Used for checking if the mouse was pressed inside the Area
var is_mouse_held = false
# The last non-empty mouse position. Used when dragging outside of the box.
var last_mouse_pos3D = null
# The last processed input touch/mouse event. To calculate relative movement.
var last_mouse_pos2D = null

onready var node_viewport = $Viewport
onready var node_quad = $puzzle_screen_plane
onready var node_area = $puzzle_screen_plane/Area

func _process(delta):
	Globals.puzzle_1_active = this_puzzle_active
	Globals.puzzle_1_viewport = node_viewport.gui_disable_input
	
func use():
	Globals.enter_puzzle($player_position, $puzzle_camera, node_viewport)
	this_puzzle_active = true
	
func look():
	if $Viewport/puzzle.complete:
		Globals.playernode.queue_message("A runic combination lock. I've already solved this one.", 3, load("res://assets/VO/runic_solved.wav"))
	else:
		Globals.playernode.queue_message("Some sort of runic combination lock", 3, load("res://assets/VO/runic.wav"))
	
func puzzle_exit():
	Globals.exit_puzzle($puzzle_camera, node_viewport)
	this_puzzle_active = false
	
func _ready():
	node_area.connect('mouse_entered', self, "_mouse_entered_area")
	node_area.connect('mouse_exited', self, "_mouse_exited_area")

func _mouse_entered_area():
	#print("wall_puzzle_1.gd: Mouse entered callback")
	is_mouse_inside = true
	
func _mouse_exited_area():
	#print("wall_puzzle_1.gd: Mouse exited callback")
	is_mouse_inside = false

func _unhandled_input(ev):
	if this_puzzle_active:
		#print("wall_puzzle_1.gd: Unhandled Input Called")
		var is_mouse_event = false
		for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
			if ev is mouse_event:
				is_mouse_event = true
				break
		#if is_mouse_event and (is_mouse_inside or is_mouse_held) and this_puzzle_active:
		if is_mouse_event:
			handle_mouse(ev)
		elif not is_mouse_event:
			node_viewport.input(ev)

func handle_mouse(ev):
	
	quad_mesh_size = node_quad.mesh.size
	if ev is InputEventMouseButton or ev is InputEventScreenTouch:
		is_mouse_held = ev.pressed
	#var mouse_pos3D = find_mouse(ev.global_position)
	var mouse_pos3D = find_mouse(ev.position)
	
	is_mouse_inside = mouse_pos3D != null
	if is_mouse_inside:
		mouse_pos3D = node_area.global_transform.affine_inverse() * mouse_pos3D
		last_mouse_pos3D = mouse_pos3D
	else:
		mouse_pos3D = last_mouse_pos3D
		if mouse_pos3D == null:
			mouse_pos3D = Vector3.ZERO
	var mouse_pos2D = Vector2(mouse_pos3D.x, -mouse_pos3D.y)
	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y
	mouse_pos2D.x = mouse_pos2D.x * node_viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * node_viewport.size.y
	ev.position = mouse_pos2D
	ev.global_position = mouse_pos2D
	if ev is InputEventMouseMotion:
		if last_mouse_pos2D == null:
			ev.relative = Vector2(0, 0)
		else:
			ev.relative = mouse_pos2D - last_mouse_pos2D
	last_mouse_pos2D = mouse_pos2D
	node_viewport.input(ev)

func find_mouse(global_position):
	var camera = $puzzle_camera

	# From camera center to the mouse position in the Area
	var from = camera.project_ray_origin(global_position)
	var dist = find_further_distance_to(camera.transform.origin)
	var to = from + camera.project_ray_normal(global_position) * dist


	# Manually raycasts the are to find the mouse position
	var result = get_world().direct_space_state.intersect_ray(from, to, [], node_area.collision_layer,false,true) #for 3.1 changes

	if result.size() > 0:
		return result.position
	else:
		return null


func find_further_distance_to(origin):
	# Find edges of collision and change to global positions
	var edges = []
	edges.append(node_area.to_global(Vector3(quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(-quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(-quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))

	# Get the furthest distance between the camera and collision to avoid raycasting too far or too short
	var far_dist = 0
	var temp_dist
	for edge in edges:
		temp_dist = origin.distance_to(edge)
		if temp_dist > far_dist:
			far_dist = temp_dist

	return far_dist
