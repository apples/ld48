extends Area2D


var velocity = Vector2(0, 0)

var reflected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += velocity * delta


func _on_EnemyFrogProjectile_body_entered(body):
	if body.is_in_group("player"):
		body.get_hit()
		$CollisionShape2D.set_deferred("disabled", true)
		hide()
		queue_free()



func _on_EnemyFrogProjectile_area_entered(area):
	if area.is_in_group("player_weapon"):
		velocity = -velocity
		reflected = true
	elif reflected and area.is_in_group("enemy"):
		area.get_hit()
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
