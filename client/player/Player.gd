extends KinematicBody2D

signal on_sleep(player)
signal on_sleep_finished(player)
signal on_death(player)

export(NodePath) var obstacle_map_path = null
onready var obstacle_map: TileMap = get_node(obstacle_map_path)

export(NodePath) var changetracker_path = null
onready var changetracker: Node = get_node(changetracker_path)

const base_move_speed = 50.0

var invuln = false
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
	if not dead and not invuln:
		Globals.player_health -= 1
		assert(Globals.player_health >= 0)
		if Globals.player_health == 0:
			be_dead()
			$SfxLose.play()
		else:
			invuln = true
			$InvulnTimer.start()
			$SfxHurt.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSpriteGrass.visible = false

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
	
	# SPRITE
	
	match facing:
		DIR_S:
			$AnimatedSprite.play("walk_S")
			$AnimatedSprite.flip_h = false
		DIR_N:
			$AnimatedSprite.play("walk_N")
			$AnimatedSprite.flip_h = false
		DIR_E:
			$AnimatedSprite.play("walk_E")
			$AnimatedSprite.flip_h = false
		DIR_W:
			$AnimatedSprite.play("walk_W")
			$AnimatedSprite.flip_h = true
	
	# OBSTACLES
	
	var obs_tile = obstacle_map.get_cellv(obstacle_map.world_to_map(position))
	
	match obs_tile:
		TileType.TALLGRASS:
			$AnimatedSpriteGrass.visible = true
			$AnimatedSpriteGrass.play()
			move_speed *= 0.5
		_:
			$AnimatedSpriteGrass.visible = false
	
	if dir.length_squared() == 0:
		$AnimatedSprite.stop()
		$AnimatedSpriteGrass.stop()
	
	# MOVE
	
	move_and_slide(dir * move_speed * base_move_speed)
	
	$AnimatedSprite.speed_scale = move_speed
	
	# ATTACK
	
	if Input.is_action_just_pressed("attack") and not $Axe.swinging and $Axe.cooldown <= 0:
		var target_poss = [obstacle_map.world_to_map(position)]
		match facing:
			DIR_S:
				target_poss.append(target_poss[0] + Vector2(0, 1))
			DIR_N:
				target_poss.append(target_poss[0] + Vector2(0, -1))
			DIR_W:
				target_poss.append(target_poss[0] + Vector2(-1, 0))
			DIR_E:
				target_poss.append(target_poss[0] + Vector2(1, 0))
		for target_pos in target_poss:
			match obstacle_map.get_cellv(target_pos):
				TileType.TALLGRASS:
					changetracker.cut_grass(target_pos)
				TileType.STICKBUSH:
					changetracker.cut_stickbush(target_pos)
		
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
		var sel = Globals.resource_order[Globals.selected_resource]
		var amt = Globals.resources[sel]
		if amt > 0:
			var did = false
			match sel:
				EventType.BERRY_BUSH:
					did = changetracker.grow_berrybush(tmpos)
				EventType.PLACE_TORCH:
					did = changetracker.place_torch(tmpos)
				EventType.PLACE_LADDER:
					did = changetracker.place_ladder(tmpos + Vector2(0, 1))
			if did:
				Globals.resources[sel] -= 1
	
	# SELECT
	
	if Input.is_action_just_pressed("switch_action"):
		Globals.selected_resource = (Globals.selected_resource + 1) % Globals.resource_order.size()

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


func _on_InvulnTimer_timeout():
	invuln = false
