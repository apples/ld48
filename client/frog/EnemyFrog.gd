extends Node2D

var projectile_scene = load("res://frog/EnemyFrogProjectile.tscn")

var target = null

var proj_speed = 20

func get_hit():
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		$AnimatedSprite.hide()
		$AnimatedSprite.stop()
		$Hitbox.disabled = true


func _on_WaitTimer_timeout():
	$AnimatedSprite.play("charge")
	$ChargeTimer.start()


func _on_ChargeTimer_timeout():
	$AnimatedSprite.play("shoot")
	var p = projectile_scene.instance()
	p.position = position
	p.velocity = (target.position - position).normalized() * proj_speed
	get_parent().add_child(p)


func _on_AnimatedSprite_animation_finished():
	match $AnimatedSprite.animation:
		"shoot":
			$AnimatedSprite.play("default")
			$WaitTimer.start()


func _on_SensorBox_body_entered(body):
	if body.is_in_group("player"):
		target = body
		$AnimatedSprite.show()
		$AnimatedSprite.play("default")
		$WaitTimer.start()
		$Hitbox.set_deferred("disabled", false)


func _on_SensorBox_body_exited(body):
	if body == target:
		target = null
		$WaitTimer.stop()
		$ChargeTimer.stop()
		$AnimatedSprite.stop()
		$AnimatedSprite.hide()
		$Hitbox.set_deferred("disabled", true)
