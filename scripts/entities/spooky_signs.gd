extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func execute():
	$block.global_transform.origin = $block_loc.global_transform.origin
	$block_2.global_transform.origin = $block_loc_2.global_transform.origin
	self.visible = true
	Globals.sound_scape.get_node("area_01").increase_bgm_pitch()
	Globals.playernode.queue_message("This isn't a good sign.", 3, load("res://assets/VO/thats_a_bad_sign.wav"))
	for obj in get_tree().get_nodes_in_group("roof_lights"):
		obj.visible = false

func _on_Area_body_entered(body):
	if body == Globals.playernode:
		if self.visible:
			Globals.playernode.in_blood = true


func _on_Area_body_exited(body):
	if body == Globals.playernode:
		if self.visible:
			Globals.playernode.in_blood = false
