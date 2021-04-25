extends Node2D

var fading_out = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("FadeIn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not fading_out and
		Globals.current_time > Globals.day_length + Globals.night_killscreen):
			fading_out = true
			$AnimationPlayer.play("FadeOut")
			$Player.be_dead()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"FadeOut":
			Globals.current_time = 0
			get_tree().reload_current_scene()
