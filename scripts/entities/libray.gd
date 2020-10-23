extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open_door():
	$secret_door/AnimationPlayer.play("open")
	$secret_door/stone_mech.play()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open":
		$secret_door/stone_mech.stop()
