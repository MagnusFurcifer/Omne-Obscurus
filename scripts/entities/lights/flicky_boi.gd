extends Spatial

var played = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_flicking_light_body_entered(body):
	if body == Globals.playernode and !played:
		$hanging_lantern/bzz.play()
		$light/AnimationPlayer.play("flicker")
		played = true
