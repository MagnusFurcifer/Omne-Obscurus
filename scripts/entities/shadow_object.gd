extends KinematicBody


var in_shadow = true
export var remove_on_observe = true
export var remove_on_observe_dist = 5

var remove_action = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func in_flashlight():
	print("shadow_object.gd: In Flashlight")
	in_shadow = false
	if !remove_action:
		$disappear_timer.start()
		remove_action = true



func _process(delta):
	if remove_action and $disappear_timer.time_left == 0:
		if remove_on_observe:
			var dst = Globals.playernode.global_transform.origin.distance_to(self.global_transform.origin)
			if dst < remove_on_observe_dist:
				self.queue_free()

func in_darkness():
	print("shadow_object.gd: In darkess")
	#self.visible = true
	in_shadow = true


func _on_disappear_timer_timeout():
	print("shadow_object.gd: Donk timeout")
	self.visible = false
