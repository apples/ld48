extends KinematicBody2D

signal on_sleep(player)
signal on_sleep_finished(player)
signal on_death(player)

export(NodePath) var floor_map_path = null
onready var floor_map: TileMap = get_node(floor_map_path)

export(NodePath) var obstacle_map_path = null
onready var obstacle_map: TileMap = get_node(obstacle_map_path)

export(NodePath) var changetracker_path = null
onready var changetracker: Node = get_node(changetracker_path)

const base_move_speed = 50.0

var invuln = false
var dead = false
var sleeping = false

var max_stamina = 100
var stamina = max_stamina
var sprinting = false

onready var start_pos = position

enum { DIR_N, DIR_S, DIR_E, DIR_W }
var facing = DIR_S

var terrain_splash_grass = load("res://player/grass.tres")
var terrain_splash_water = load("res://player/waistwater_spriteframes.tres")

enum Terrain { NONE, TALLGRASS, SWAMP }
var current_terrain = Terrain.NONE
var time_in_terrain = 0.0

enum DOT { NONE, DROWNING }
var dot_effect = DOT.NONE

onready var anim_tree = $AnimationTree
onready var anim_tree_playback = anim_tree["parameters/playback"]
onready var anim_tree_normal_playback = anim_tree["parameters/normal/state_machine/playback"]

func set_anim_tree_normal_playback_speed(value: float):
	 anim_tree["parameters/normal/playback_speed/scale"] = value

func be_dead():
	dead = true
	$AnimatedSprite.rotation_degrees = 90
	anim_tree_playback.travel("normal")
	anim_tree_normal_playback.travel("default")
	emit_signal("on_death", self)

func go_to_sleep():
	dead = true
	sleeping = true
	emit_signal("on_sleep", self)
	$MusicSleep.play()

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

func enable_canopy_mask():
	$CanopyMask.show()

func disable_canopy_mask():
	$CanopyMask.hide()

func apply_dot(dot: int):
	dot_effect = dot

func clear_dot():
	dot_effect = DOT.NONE

func _update_terrain(terrain: int, delta: float):
	if terrain != current_terrain:
		current_terrain = terrain
		time_in_terrain = 0.0
		
		match terrain:
			Terrain.TALLGRASS:
				$TerrainSplash.frames = terrain_splash_grass
				$TerrainSplash.show()
			Terrain.SWAMP:
				$TerrainSplash.frames = terrain_splash_water
				$TerrainSplash.show()
			_:
				$TerrainSplash.hide()
	else:
		time_in_terrain += delta
	
	if dot_effect != DOT.DROWNING and current_terrain == Terrain.SWAMP && time_in_terrain > 3:
		apply_dot(DOT.DROWNING)
		anim_tree_playback.travel("drowning")
	elif dot_effect == DOT.DROWNING and current_terrain != Terrain.SWAMP:
		clear_dot()
		anim_tree_playback.travel("normal")

# Called when the node enters the scene tree for the first time.
func _ready():
	$TerrainSplash.hide()
	$CanopyMask.hide()
	anim_tree_playback.start("normal")
	anim_tree_normal_playback.start("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		_process_dead(delta)
	else:
		_process_alive(delta)

func _input(event):
	if event.is_action_pressed("sprint") && stamina >= 5:
		sprinting = true
	elif event.is_action_released("sprint"):
		sprinting = false

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
	
#	if Input.is_action_just_pressed("sprint") && stamina >= 5:
#		sprinting = true
#	elif Input.is_action_released("sprint"):
#		sprinting = false
		
	if sprinting && stamina > 0:
		stamina -= 1
		move_speed *= 2
	else:
		sprinting = false
		if stamina <= max_stamina:
			stamina += .5
	
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
			anim_tree_normal_playback.travel("walk_S")
		DIR_N:
			anim_tree_normal_playback.travel("walk_N")
		DIR_E:
			anim_tree_normal_playback.travel("walk_E")
		DIR_W:
			anim_tree_normal_playback.travel("walk_W")
	
	# TERRAIN
	
	var floor_tile = floor_map.get_cellv(floor_map.world_to_map(position))
	var obs_tile = obstacle_map.get_cellv(obstacle_map.world_to_map(position))
	
	if obs_tile == TileType.TALLGRASS:
		_update_terrain(Terrain.TALLGRASS, delta)
	elif floor_tile == TileType.SWAMP_WATER:
		_update_terrain(Terrain.SWAMP, delta)
	else:
		_update_terrain(Terrain.NONE, delta)
	
	if dir.length_squared() == 0:
		anim_tree_normal_playback.travel("default")
	
	# MOVE
	
	match current_terrain:
		Terrain.TALLGRASS, Terrain.SWAMP:
			move_speed *= 0.5
	
	move_and_slide(dir * move_speed * base_move_speed)
	
	set_anim_tree_normal_playback_speed(move_speed)
	
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
	
	# BERRY BUSH
	
	if obstacle_map.get_cellv(obstacle_map.world_to_map(position)) == TileType.BERRYBUSH4:
		if Globals.player_health < 5:
			Globals.player_health += 1
			obstacle_map.set_cellv(obstacle_map.world_to_map(position), TileType.BERRYBUSH3)

func _process_dead(delta):
	pass

func _physics_process(delta):
	pass

func _on_MusicSleep_finished():
	emit_signal("on_sleep_finished", self)


func _on_InvulnTimer_timeout():
	invuln = false



func _on_SkytoneEffect_skytone_color(color):
	$CanopyMask.color = color
