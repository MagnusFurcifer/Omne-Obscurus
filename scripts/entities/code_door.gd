extends KinematicBody

export var open = false
export var locked = false

func _ready():
	pass # Replace with function body.

func lock_door():
	locked = true

func unlock_door():
	print("door.gd: Unlocking door")
	locked = false
	
func slam():
	open = false
	$AnimationPlayer.playback_speed = 4
	$AnimationPlayer.play("close")

func use():
	$AnimationPlayer.playback_speed = 1
	if !$AnimationPlayer.is_playing():
		if open:
			$AnimationPlayer.play("close")
			Globals.playernode.get_node("gameplay_sounds/door_close").play()
			open = false
		else:
			if !locked:
				$AnimationPlayer.play("open")
				Globals.playernode.get_node("gameplay_sounds/door_open").play()
				Globals.spooky_set_pieces.get_node("spooky_signs").execute()
				open = true
			else:
				Globals.playernode.get_node("gameplay_sounds/door_locked").play()
				Globals.playernode.queue_message("Hmmmm. Won't budge. Locked up tight", 5)
