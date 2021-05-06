tool
extends Node2D

export(Enemy.EnemyType) var type = Enemy.EnemyType.FOX setget set_type
export(float, 0, 2) var time_threshold = 0
export(float, 0, 1, .05) var spawn_chance = 1
export(float, 0, 512, 1) var spawn_radius = 128 setget set_spawn_radius
export(float) var min_spawn_radius = 32
export(bool) var require_grass = true

export(bool) var enable_shimmie = true
export(float, 0.25, 5, 0.25) var shimmie_wait_min = 1 setget set_shimmie_wait_min
export(float, 0.25, 10, 0.25) var shimmie_wait_max = 2

onready var holder = get_parent()

var texmap = {
	Enemy.EnemyType.FOX: "res://enemy/fox_icon.tres",
	Enemy.EnemyType.WOLF: "res://enemy/wolf_icon.tres",
}

var rng = RandomNumberGenerator.new()

func set_type(value: int):
	type = value
	$Sprite.texture = load(texmap[type])

func set_spawn_radius(value: float):
	spawn_radius = value
	if value == 0:
		$SpawnRadius/CollisionShape2D.shape = null
	else:
		if $SpawnRadius/CollisionShape2D.shape == null:
			$SpawnRadius/CollisionShape2D.shape = CircleShape2D.new()
		$SpawnRadius/CollisionShape2D.shape.radius = spawn_radius

func set_shimmie_wait_min(value: float):
	shimmie_wait_min = value
	if shimmie_wait_min > shimmie_wait_max:
		shimmie_wait_max = shimmie_wait_min

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	$Sprite.texture = load(texmap[type])
	$SpawnRadius/CollisionShape2D.shape = CircleShape2D.new()
	$SpawnRadius/CollisionShape2D.shape.radius = spawn_radius
	if Engine.editor_hint:
		$Sprite.show()
		$ShimmieTimer.stop()
	else:
		$Sprite.hide()
		if enable_shimmie:
			$ShimmieTimer.start(rng.randf_range(shimmie_wait_min, shimmie_wait_max))
		else:
			$ShimmieTimer.paused = true


func _on_SpawnRadius_body_entered(body):
	if not Engine.editor_hint and body.is_in_group("player"):
		_try_spawn(body)

func _try_spawn(target):
	var in_range = (target.position - position).length() >= min_spawn_radius
	if in_range and rng.randf() < spawn_chance:
		holder.try_spawn(type, position,require_grass)
		queue_free()


func _on_ShimmieTimer_timeout():
	if holder.is_grass(position):
		$ShimmieSprite.show()
		$ShimmieSprite.frame = 0
		$ShimmieSprite.play()
	else:
		$ShimmieTimer.paused = true


func _on_ShimmieSprite_animation_finished():
	$ShimmieSprite.hide()
	$ShimmieSprite.stop()
	$ShimmieTimer.start(rng.randf_range(shimmie_wait_min, shimmie_wait_max))
