extends Node2D

var enemy_scene = preload("res://Enemy/Enemy.tscn")

var fading_out = false

var lock_reset = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_lock()
	$ChangeTracker.load_and_replay_all($Navigation2D/TileMapFloor, $Navigation2D/TileMapObstacles)
	if Globals.strand_data != null:
		$ChangeTracker.apply_strand_data(Globals.strand_data)
	$Player/Camera/FadeSprite.modulate = "#000000"
	$AnimationPlayer.play("FadeIn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not fading_out and
		Globals.current_time > Globals.day_length + Globals.night_killscreen && fmod(Globals.current_time, 10) < .05):
			#$Player.get_hit()
			var enemy = enemy_scene.instance()
			enemy.position.x = 100#rng.randf_range(spawn_start_x, spawn_start_x + spawn_range_x)
			enemy.position.y = 100#rng.randf_range(spawn_start_y, spawn_start_y + spawn_range_y)
			add_child(enemy)

func _lock():
	lock_reset += 1
	print("lock " + str(lock_reset))

func _unlock():
	assert(lock_reset > 0)
	lock_reset -= 1
	print("lock " + str(lock_reset))
	if lock_reset == 0:
		print("Resetting")
		Globals.current_time = 0
		Globals.player_health = 6 if $Player.sleeping else 5
		get_tree().reload_current_scene()


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"FadeOut":
			_lock()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"FadeOut":
			fading_out = false
			_unlock()


func _on_SleepArea_body_entered(body):
	if body.is_in_group("player"):
		body.go_to_sleep()


func _on_Player_on_sleep(player):
	fading_out = true
	$AnimationPlayer.play("FadeOut")
	$ChangeTracker.commit()


func _on_Player_on_death(player):
	fading_out = true
	$AnimationPlayer.play("FadeOut")
	$ChangeTracker.commit()
	_unlock()


func _on_Player_on_sleep_finished(player):
	_unlock()


func _on_ChangeTracker_commit_started():
	_lock()

func _on_ChangeTracker_commit_complete():
	if StrandService.is_online():
		StrandService.EndDay(Globals.current_day, self, "_on_StrandService_EndDay_complete")
	else:
		_unlock()

func _on_StrandService_EndDay_complete(json):
	print("Day ended")
	Globals.strand_data = json
	Globals.save_strand()
	_unlock()


