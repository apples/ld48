extends Area2D

var cooldown = 0

var swinging = false

func swing():
	if cooldown == 0 and not swinging:
		$SfxAxe.play()
		show()
		$CollisionShape2D.disabled = false
		$AxeSprite.play()
		swinging = true


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
	swinging = false


func _on_Axe_body_entered(body):
	if body.is_in_group("enemy"):
		print("hit: " + body.name)
		body.get_hit()


func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		if cooldown < 0:
			cooldown = 0
