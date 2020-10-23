extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var bgm_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func increase_bgm_pitch():
	$AnimationPlayer.play("increase_bgm_pitch")

func _on_Area_body_entered(body):
	if body == Globals.playernode && !bgm_active:
		print("area_01_sound_manager.gd: Player entered BGM start area")
		$AnimationPlayer.play("bgm_fade_in")
		bgm_active = true


func _on_gbm_finished():
	if bgm_active:
		$gbm.play()
