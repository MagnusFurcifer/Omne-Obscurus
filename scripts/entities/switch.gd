extends StaticBody


var pulled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func use():
	if !pulled:
		pulled = true
		$AnimationPlayer.play("switch")
		get_parent().open_door()
		
