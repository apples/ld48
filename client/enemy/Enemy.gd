extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player = null
var move_speed = 50
var dir = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	$AnimatedSprite.play("foxRun")
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dir =  (player.position - position).normalized()
	move_and_slide(dir * move_speed)
#	pass
