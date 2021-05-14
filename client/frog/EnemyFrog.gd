tool
extends Node2D

var projectile_scene = load("res://frog/EnemyFrogProjectile.tscn")

var target = null

var proj_speed = 20

onready var playback = $AnimationTree["parameters/playback"]

func get_hit():
	queue_free()

func spawn_projectile():
	_print_status("spawn_projectile")
	assert(target != null)
	var p = projectile_scene.instance()
	p.position = position
	p.velocity = (target.position - position).normalized() * proj_speed
	get_parent().add_child(p)

func dive():
	_print_status("dive")
	$Hitbox.set_deferred("disabled", true)
	$Sprite.hide()

func rise():
	_print_status("rise")
	$Hitbox.set_deferred("disabled", false)
	$Sprite.show()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		playback.start("hide")
	else:
		playback.start("wait")

func _print_status(msg):
	print(msg, ": ", playback.get_current_node(), "(", !$WaitTimer.is_stopped(), ", ", !$ChargeTimer.is_stopped(), ") -> ", target)

func _on_WaitTimer_timeout():
	_print_status("_on_WaitTimer_timeout")
	playback.travel("begin_charge")


func _on_ChargeTimer_timeout():
	_print_status("_on_ChargeTimer_timeout")
	playback.travel("shoot")


func _on_SensorBox_body_entered(body):
	if target == null and body.is_in_group("player"):
		_print_status("_on_SensorBox_body_entered")
		target = body
		playback.travel("begin_wait")


func _on_TrackingZone_body_exited(body):
	if body == target:
		_print_status("_on_SensorBox_body_exited")
		target = null
		playback.travel("hide")


func _on_ComfortZone_body_entered(body):
	if body.is_in_group("player"):
		playback.travel("hide")


func _on_ComfortZone_body_exited(body):
	if body.is_in_group("player"):
		if target != null:
			playback.travel("begin_wait")

