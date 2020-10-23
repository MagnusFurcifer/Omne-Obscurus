extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var door = null

var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for obj in get_tree().get_nodes_in_group("other_room_door"):
		door = obj



func _on_door_slam_trigger_body_entered(body):
	if body == Globals.playernode and !triggered:
		door.slam()
		$slam.play()
		triggered = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "close":
		$laugh.play()
