extends Spatial

var started = false

func _ready():
	$AnimationPlayer.play("default")

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play("default")

func _on_Area_body_entered(body):
	if body == Globals.playernode and !started:
		get_parent().get_node("sting").play()
		get_parent().get_node("sting/Timer").start()
		started = true

func _on_AnimationPlayer_movement_animation_finished(anim_name):
	if anim_name == "crawl_past":
		Globals.sound_scape.get_node("misc/door_slam").play()
		get_parent().queue_free()
		Globals.playernode.queue_message("What the hell was that?", 3, load("res://assets/VO/what_the_hell_was_that.wav"))

func _on_sting_timer_timeout():
	get_parent().get_node("AnimationPlayer").play("crawl_past")
