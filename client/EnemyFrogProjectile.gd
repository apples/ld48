extends Area2D


var velocity = Vector2(0, 0)

var reflected = false

var hitting_enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += velocity * delta


func _on_any_entered(obj):
	if not reflected and obj.is_in_group("player_weapon"):
		velocity = -velocity
		reflected = true
		if hitting_enemies.size() > 0:
			for e in hitting_enemies:
				e.get_hit()
			hitting_enemies.clear()
			$CollisionShape2D.set_deferred("disabled", true)
			queue_free()
	elif obj.is_in_group("enemy"):
		if reflected:
			obj.get_hit()
			$CollisionShape2D.set_deferred("disabled", true)
			queue_free()
		else:
			hitting_enemies.append(obj)

func _on_any_exited(obj):
	if obj.is_in_group("enemy"):
		hitting_enemies.erase(obj)
