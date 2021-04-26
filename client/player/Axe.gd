extends Area2D

var cooldown = 0

func swing():
	if cooldown == 0:
		show()
		$CollisionShape2D.disabled = false
		$AxeSprite.play()
		cooldown = .5


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	$CollisionShape2D.disabled = true
	$AxeSprite.stop()



func _on_AxeSprite_animation_finished():
	hide()
	$CollisionShape2D.disabled = true
	$AxeSprite.stop()
	cooldown = .5


func _on_Axe_body_entered(body):
	if(body.is_in_group("Enemy")):#body.name == "Enemy"):#change to group check
		print("hit: " + body.name)
		body.get_hit()


func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		if cooldown < 0:
			cooldown = 0
