extends Node2D

var screen_size = Vector2(640, 400)
onready var current_line2D = Line2D.new()
var curve2d : Curve2D
var last_position : Vector2
export var speed = 5
var started = false #stops the pathfollow setting off without a path

var mouse_inside_drawing_area = false

func _ready():
	screen_size = get_viewport_rect().size
	add_child(current_line2D)

func puzzle_complete():
	get_parent().get_parent().get_parent().get_parent().get_node("door").unlock_door()

func _on_exit_button_pressed():
	print("Exit Event")
	puzzle_complete()
	get_parent().get_parent().puzzle_exit()

func _on_back_button_pressed():
	print("Back Event")
	current_line2D.queue_free()
	current_line2D = Line2D.new()
	last_position = Vector2()
	add_child(current_line2D)
	curve2d = null
	started = false
	pass

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		print("DRAWING")
		started = true
		curve2d = null
		#start from the last position except for the first line
		if current_line2D.points.size() == 0 && last_position:
			current_line2D.add_point(last_position)
		#draw the points
		if event is InputEventMouseMotion:
			current_line2D.add_point(event.position)
	elif started:
		#curve2d is currently null
		if !curve2d:
			curve2d = Curve2D.new()
			#getting the last position as the start for the next path
			last_position = current_line2D.points[current_line2D.points.size()-1]
			#add all the points to curve2d
			for i in current_line2D.points.size():
				curve2d.add_point(current_line2D.points[i])
			#assign the curve
			$Path2D.curve = curve2d
			#set pathfollow to the beginning
			$Path2D/PathFollow2D.unit_offset = 0
			#follow the path
			while $Path2D/PathFollow2D.unit_offset < 1:
				$Path2D/PathFollow2D.offset += speed
				yield(get_tree(),"idle_frame")
			#clear for next path
			current_line2D.points = PoolVector2Array()
