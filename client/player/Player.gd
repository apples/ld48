extends KinematicBody2D

signal on_sleep(player)
signal on_sleep_finished(player)
signal on_death(player)

export(NodePath) var obstacle_map_path = null
onready var obstacle_map: TileMap = get_node(obstacle_map_path)

export(NodePath) var changetracker_path = null
onready var changetracker: Node = get_node(changetracker_path)

const base_move_speed = 50.0

var dead = false
var sleeping = false

onready var start_pos = position

enum { DIR_N, DIR_S, DIR_E, DIR_W }
var facing = DIR_S

func be_dead():
	dead = true
	$AnimatedSprite.rotation_degrees = 90
	$AnimatedSprite.stop()
	emit_signal("on_death", self)

func go_to_sleep():
	dead = true
	sleeping = true
	emit_signal("on_sleep", self)
	$MusicSleep.play()

func reset():
	dead = false
	sleeping = false
	facing = DIR_S
	position = start_pos
	$AnimatedSprite.rotation_degrees = 0
	$AnimatedSprite.stop()

func get_hit():
	Globals.player_health -= 1
	if Globals.player_health <= 0:
		be_dead()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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
	
	# FACING
	
	if dir.x < 0:
		facing = DIR_W
	if dir.x > 0:
		facing = DIR_E
	if dir.y < 0:
		facing = DIR_N
	if dir.y > 0:
		facing = DIR_S
	
	# OBSTACLES
	
	var obs_tile = obstacle_map.get_cellv(obstacle_map.world_to_map(position))
	
	match obs_tile:
		TileType.TALLGRASS:
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
		var target_pos = obstacle_map.world_to_map(position) + dir
		match obstacle_map.get_cellv(target_pos):
			TileType.TALLGRASS:
				changetracker.cut_grass(target_pos)
		
		match facing:
			DIR_N:
				$Axe.rotation_degrees = 180
			DIR_S:
				$Axe.rotation_degrees = 0
			DIR_E:
				$Axe.rotation_degrees = 180 + 90
			DIR_W:
				$Axe.rotation_degrees = 90
		$Axe.swing()
	
	# CONSTRUCT
	
	if Input.is_action_just_pressed("construct"):
		var tmpos = obstacle_map.world_to_map(position)
		var t = obstacle_map.get_cellv(tmpos)
		match t:
			TileType.NONE, TileType.BERRYBUSH0, TileType.BERRYBUSH1, TileType.BERRYBUSH2, TileType.BERRYBUSH3:
				changetracker.grow_berrybush(tmpos)

func _process_dead(delta):
	pass

func _physics_process(delta):
	pass

func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.frame % 2 == 0:
		var obs_tile = obstacle_map.get_cellv(obstacle_map.world_to_map(position))
		
		match obs_tile:
			TileType.TALLGRASS:
				$SfxGrass.play()
			_:
				pass

func _on_MusicSleep_finished():
	emit_signal("on_sleep_finished", self)
