extends KinematicBody2D

signal on_sleep(player)

export(NodePath) var obstacle_map_path = null
onready var obstacle_map: TileMap = get_node(obstacle_map_path)

const TALLGRASS_TILE = 1
const BERRYBUSH_TILE0 = 13
const BERRYBUSH_TILE1 = 14
const BERRYBUSH_TILE2 = 15
const BERRYBUSH_TILE3 = 16
const BERRYBUSH_TILE4 = 17

const base_move_speed = 50.0

var dead = false

onready var start_pos = position

func be_dead():
	dead = true
	$AnimatedSprite.rotation_degrees = 90
	$AnimatedSprite.stop()

func go_to_sleep():
	dead = true
	emit_signal("on_sleep", self)
	$MusicSleep.play()

func reset():
	dead = false
	position = start_pos
	$AnimatedSprite.rotation_degrees = 0
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
	
	# INPUT - MOVE
	
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
	
	# OBSTACLES
	
	var obs_tile = obstacle_map.get_cellv(obstacle_map.world_to_map(position))
	
	match obs_tile:
		TALLGRASS_TILE:
			$AnimatedSprite.play("grass")
			move_speed *= 0.5
		_:
			$AnimatedSprite.play("default")
	
	if dir.length_squared() == 0:
		$AnimatedSprite.stop()
	
	# MOVE
	
	move_and_slide(dir * move_speed * base_move_speed)
	
	$AnimatedSprite.speed_scale = move_speed
	
	# ATTACK
	
	if Input.is_action_just_pressed("attack"):
		obstacle_map.set_cellv(obstacle_map.world_to_map(position) + dir, -1)
	
	# CONSTRUCT
	
	if Input.is_action_just_pressed("construct"):
		var tmpos = obstacle_map.world_to_map(position)
		var t = obstacle_map.get_cellv(tmpos)
		match t:
			TileMap.INVALID_CELL:
				obstacle_map.set_cellv(tmpos, BERRYBUSH_TILE0)
			BERRYBUSH_TILE0, BERRYBUSH_TILE1, BERRYBUSH_TILE2, BERRYBUSH_TILE3:
				obstacle_map.set_cellv(tmpos, t + 1)
			BERRYBUSH_TILE4:
				obstacle_map.set_cellv(tmpos, t - 1)

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
