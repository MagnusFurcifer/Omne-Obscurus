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

func use():
	if !$AnimationPlayer.is_playing():
		if open:
			$AnimationPlayer.play("close")
			Globals.playernode.get_node("gameplay_sounds/door_close").play()
			open = false
		else:
			if !locked:
				$AnimationPlayer.play("open")
				Globals.playernode.get_node("gameplay_sounds/door_open").play()
				open = true
			else:
				Globals.playernode.get_node("gameplay_sounds/door_locked").play()
				Globals.playernode.queue_message("Hmmmm. Won't budge. Locked up tight", 5, load("res://assets/VO/locked_up_tight.wav"))
