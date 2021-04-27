extends Node2D

var enemy_scene = load("res://Enemy/Enemy.tscn")

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
	pass

func _lock():
	lock_reset += 1
	print("lock " + str(lock_reset))

func _unlock():
	assert(lock_reset > 0)
	lock_reset -= 1
	print("lock " + str(lock_reset))
	if lock_reset == 0:
		print("Resetting")
		Globals.reset_player($Player.sleeping)
		Globals.advance_day()
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
	print("Sleep trigger")
	if body.is_in_group("player"):
		body.go_to_sleep()


func _on_Player_on_sleep(player):
	print("Player sleeping")
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


