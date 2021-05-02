extends KinematicBody2D
class_name Enemy

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player = null

var move_speed = 50
var dir = Vector2(0, 0)
var facing_right = false
var health = 1

enum EnemyType { FOX, WOLF }
export(EnemyType) var type = EnemyType.FOX

var fox_sprites = load("res://enemy/fox.tres")
var wolf_sprites = load("res://enemy/wolf.tres")

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	match type:
		EnemyType.FOX:
			$AnimatedSprite.frames = fox_sprites
		EnemyType.WOLF:
			$AnimatedSprite.frames = wolf_sprites
	$AnimatedSprite.play("run")

func get_hit():
	if not dead:
		if health > 0:
			health -= 1
		if health <= 0:
			dead = true
			$DeadTimer.start()
			$CollisionPolygon2D.set_deferred("disabled", true)
			$AnimatedSprite.rotation_degrees = 90
			$AnimatedSprite.stop()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not dead:
		var vec = player.position - position
		if vec.length() < 16 * 5:
			$AnimatedSprite.play()
			dir =  vec.normalized()
			if(dir.x > 0):
				if(!facing_right):
					facing_right = true
					$AnimatedSprite.flip_h = true
			else:
				if(facing_right):
					facing_right = false
					$AnimatedSprite.flip_h = false
			move_and_slide(dir * move_speed)
			
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if(collision.collider.name == "Player"):
					player.get_hit()
		else:
			$AnimatedSprite.stop()


func _on_DeadTimer_timeout():
	match type:
		EnemyType.FOX:
			queue_free()
		EnemyType.WOLF:
			health = 1
			dead = false
			$CollisionPolygon2D.set_deferred("disabled", false)
			$AnimatedSprite.rotation_degrees = 0
