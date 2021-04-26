extends Area2D


func swing():
	show()
	$CollisionShape2D.disabled = false
	$AxeSprite.play()
#	for body in get_overlapping_bodies():
#		if(body.is_in_group("Enemy")):#body.name == "Enemy"):#change to group check
#			print("hit: " + body.name)
#			body.get_hit()


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	$CollisionShape2D.disabled = true
	$AxeSprite.stop()



func _on_AxeSprite_animation_finished():
	hide()
	$CollisionShape2D.disabled = true
	$AxeSprite.stop()


func _on_Axe_body_entered(body):
	if(body.is_in_group("Enemy")):#body.name == "Enemy"):#change to group check
		print("hit: " + body.name)
		body.get_hit()
