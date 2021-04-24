extends KinematicBody2D

var move_speed = 50.0

var dir
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dir = Vector2(0, 0)
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0
	if Input.is_action_pressed("move_down"):
		dir.y += 1.0
	if Input.is_action_pressed("move_up"):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_SHIFT):
		move_and_slide(dir * move_speed * 2)
	else:
		move_and_slide(dir * move_speed)

func _physics_process(delta):
	pass
