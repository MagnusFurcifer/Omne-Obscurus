extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var cracked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Area_body_entered(body):
	if body == Globals.playernode and !cracked:
		$hanging_lantern/bzz.play()
		$hanging_lantern/crack.play()
		$hanging_lantern.visible = false
		$light.visible = false
		cracked = true
