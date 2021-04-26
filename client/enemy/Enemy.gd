extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player = null

var move_speed = 50
var dir = Vector2(0, 0)
var facing_right = false
var health = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	$AnimatedSprite.play("foxRun")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dir =  (player.position - position).normalized()
	if(dir.x > 0):
		if(!facing_right):
			facing_right = true
			$AnimatedSprite.flip_h = true
		#$AnimatedSprite.play("foxRunRight")
	else:
		if(facing_right):
			facing_right = false
			$AnimatedSprite.flip_h = false
	move_and_slide(dir * move_speed)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if(collision.collider.name == "Player"):
			player.get_hit()
