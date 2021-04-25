extends KinematicBody2D

export(NodePath) var obstacle_map_path = null
onready var obstacle_map: TileMap = get_node(obstacle_map_path)

#export(NodePath) var tileMap = null
#onready var worldMap: TileMap = get_node(tileMap)

const TALLGRASS_TILE = 1

export(float) var base_move_speed = 50.0

var dead = false

func be_dead():
	dead = true
	$AnimatedSprite.rotation_degrees = 90
	$AnimatedSprite.stop()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		_process_dead(delta)
	else:
		_process_alive(delta)

func _process_alive(delta):
	var dir = Vector2(0, 0)
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0
	if Input.is_action_pressed("move_down"):
		dir.y += 1.0
	if Input.is_action_pressed("move_up"):
		dir.y -= 1.0
	
	var move_speed = 0.0 if dir.length_squared() == 0 else 1.0
	
	if Input.is_key_pressed(KEY_SHIFT):
		move_speed *= 2
	
	var obs_tile = obstacle_map.get_cellv(obstacle_map.world_to_map(position))
	
	match obs_tile:
		TALLGRASS_TILE:
			$AnimatedSprite.play("grass")
			move_speed *= 0.5
		_:
			$AnimatedSprite.play("default")
	
	if dir.length_squared() == 0:
		$AnimatedSprite.stop()
	
	move_and_slide(dir * move_speed * base_move_speed)
	
	if Input.is_action_just_pressed("attack"):
		obstacle_path.set_cellv(obstacle_path.world_to_map(position) + dir, 0)
	
	$AnimatedSprite.speed_scale = move_speed

func _process_dead(delta):
	pass

func _physics_process(delta):
	pass

func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.frame % 2 == 0:
		var obs_tile = obstacle_map.get_cellv(obstacle_map.world_to_map(position))
		
		match obs_tile:
			TALLGRASS_TILE:
				$SfxGrass.play()
			_:
				pass
