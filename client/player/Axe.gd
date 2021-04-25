extends Area2D


func swing():
	show()
	$CollisionShape2D.disabled = false
	$AxeSprite.play()


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	$CollisionShape2D.disabled = true
	$AxeSprite.stop()



func _on_AxeSprite_animation_finished():
	hide()
	$CollisionShape2D.disabled = true
	$AxeSprite.stop()
