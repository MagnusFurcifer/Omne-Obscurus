extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("roll")
	$vo.play()
	
func _process(delta):
	if Input.is_action_just_pressed("action_use"):
		LoadingScreen.load_scene("res://scenes/World.tscn")
		$vo.stop()


func _on_AnimationPlayer_animation_finished(anim_name):
	print("story_preamble.gd: Animation over. Loading game")
	if anim_name == "roll":
		LoadingScreen.load_scene("res://scenes/World.tscn")
		$vo.stop()
