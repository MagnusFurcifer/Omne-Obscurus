extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("line_1")
	

func _process(delta):
	if Input.is_action_just_pressed("action_use"):
		get_tree().quit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "line_1":
		$AnimationPlayer.play("line_2")
	elif anim_name == "line_2":
		$AnimationPlayer.play("line_3")
	elif anim_name == "line_3":
		$AnimationPlayer.play("line_4")
