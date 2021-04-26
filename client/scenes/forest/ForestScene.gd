extends Node2D

var enemy_scene = preload("res://Enemy/Enemy.tscn")

var fading_out = false

var reset_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$ChangeTracker.load_and_replay_all($Navigation2D/TileMapFloor, $Navigation2D/TileMapObstacles)
	$AnimationPlayer.play("FadeIn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not fading_out and
		Globals.current_time > Globals.day_length + Globals.night_killscreen && fmod(Globals.current_time, 10) < .1):
			#$Player.get_hit()
			var enemy = enemy_scene.instance()
			enemy.position.x = 100#rng.randf_range(spawn_start_x, spawn_start_x + spawn_range_x)
			enemy.position.y = 100#rng.randf_range(spawn_start_y, spawn_start_y + spawn_range_y)
			add_child(enemy)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"FadeOut":
			fading_out = false
			Globals.current_time = 0
			Globals.player_health = 6 if $Player.sleeping else 5
			reset_counter -= 1
			if reset_counter == 0:
				get_tree().reload_current_scene()


func _on_SleepArea_body_entered(body):
	if body.is_in_group("player"):
		body.go_to_sleep()


func _on_Player_on_sleep(player):
	fading_out = true
	$AnimationPlayer.play("FadeOut")
	reset_counter = 2
	$ChangeTracker.commit()


func _on_Player_on_death(player):
	fading_out = true
	$AnimationPlayer.play("FadeOut")
	reset_counter = 1


func _on_Player_on_sleep_finished(player):
	reset_counter -= 1
	if reset_counter == 0:
		get_tree().reload_current_scene()
