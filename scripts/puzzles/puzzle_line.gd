extends StaticBody2D

var can_draw = true
var drawing = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func reset():
	$Line2D.clear_points()
	can_draw = true
	drawing = false

func _input(ev):
	if get_parent().get_parent().get_parent().this_puzzle_active:
		if ev is InputEventMouse:
			if (ev.position.y > 100 && ev.position.y < 440) && (ev.position.x > 142 && ev.position.x < 364):
				print("puzzle_line.gd: Cursor in center")
				Input.set_custom_mouse_cursor(load("res://assets/puzzles/controls/cursor_brush.png"))
				if ev.is_action_pressed("action_use") and can_draw and $Line2D.get_point_count() == 0:
					drawing = true
					$Line2D.add_point(ev.position)
					$Line2D.add_point(ev.position)
				elif ev.is_action_released("action_use"):
					can_draw = false
					drawing = false
					$CollisionShape2D.shape.a = $Line2D.get_point_position(0)
					$CollisionShape2D.shape.b = $Line2D.get_point_position(1)
				if can_draw:
					$Line2D.set_point_position(1, get_local_mouse_position())
				if ev is InputEventMouseMotion and drawing:
					$Line2D.points[1] = ev.position
			else: #This is if the cursor isn't in the center area
				Input.set_custom_mouse_cursor(load("res://assets/puzzles/controls/cursor_dot.png"))
				pass
