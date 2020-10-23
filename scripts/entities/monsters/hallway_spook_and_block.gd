extends Spatial

var triggered = false
var started_sprinting = false
var block = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Drunk Run Forward/AnimationPlayer".get_animation("default").loop = true
	$"Drunk Run Forward/AnimationPlayer".play("default")

func _process(delta):
	if triggered:
		if !block:
			$block.global_transform.origin = $block_loc.global_transform.origin
			$slam.play()
			block = true
			$"Drunk Run Forward/AnimationPlayer".play("default")

		if Globals.playernode.get_node("head/Camera/scare_ray").is_colliding():
			if Globals.playernode.get_node("head/Camera/scare_ray").get_collider() == $"Drunk Run Forward":
				if !started_sprinting:
					$AnimationPlayer.play("run_torwards_player")
					$scare.play()
					started_sprinting = true
		

func _on_trigger_body_entered(body):
	if body == Globals.playernode and !triggered:
		triggered = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "run_torwards_player":
		self.queue_free()
