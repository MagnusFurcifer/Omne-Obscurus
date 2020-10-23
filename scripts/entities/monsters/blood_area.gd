extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
 Globals.spooky_set_pieces.get_node("spooky_signs").visible = false





func _on_blood_area_body_entered(body):
	print("blood_area.gd: what in tarnation")
	if body == Globals.playernode:
		Globals.spooky_set_pieces.get_node("spooky_signs").visible = true
