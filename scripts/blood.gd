extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func look():
	if get_parent().get_parent().get_parent().visible:
		Globals.playernode.queue_message("Oh god. Is this...blood?", 4, load("res://assets/VO/ohgod_blood.wav"))
