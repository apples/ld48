tool
extends ColorRect

enum EnemyType { FOX, WOLF }
export(EnemyType) var type = EnemyType.FOX

export(NodePath) var holder_path = ".."
onready var holder = get_node(holder_path)

export(float) var time_threshold = 0

var enemy_scene = preload("res://enemy/Enemy.tscn")

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		visible = true
	else:
		visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.editor_hint:
		_game_process(delta)

func _game_process(delta):
	if Globals.current_time > time_threshold:
		rng.randomize()
		var e = enemy_scene.instance()
		e.type = type
		e.position.x = rng.randf_range(margin_left, margin_right)
		e.position.y = rng.randf_range(margin_top, margin_bottom)
		holder.add_child(e)
		time_threshold = 9999999
		queue_free()
