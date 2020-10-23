extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_end_trigger_body_entered(body):
	if body == Globals.playernode:
		Globals.sound_scape.get_node("area_01").bgm_active = false
		Globals.sound_scape.get_node("area_01/gbm").stop()
		$violin.play()
		Globals.playernode.shutdown_lights()
		Globals.playernode.first_person_camera.current = false
		Globals.playernode.queue_free()
		$geometry/roofs/Camera.current = true
		get_parent().get_parent().get_node("WorldEnvironment").environment.fog_enabled = false
		$geometry/roofs/Camera/AnimationPlayer.play("look_at_stuff")
		$geometry/roofs/final_cutscene_trigger_delay.start()
		pass # Replace with function body.

func _on_cutscene_animation_finished(anim_name):
	if anim_name == "look_at_stuff":
		$geometry/roofs/Camera/AnimationPlayer.play("look_at_roof")
		$geometry/roofs/AnimationPlayer.play("open_shutters")
		$moon_stuff/AnimationPlayer.play("room_raise")
		$singing.play()

func _on_final_cutscene_trigger_delay_timeout():
	$lights/cavern_light.visible = true
	pass # Replace with function body.

func _on_moon_animation_finished(anim_name):
	if anim_name == "room_raise":
		$moon_stuff/AnimationPlayer.play("black_hole")
	elif anim_name == "black_hole":
		$audio_anim.play("make_singing_louder")
		get_tree().change_scene("res://scenes/final_scene.tscn")
