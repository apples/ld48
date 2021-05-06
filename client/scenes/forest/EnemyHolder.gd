extends YSort

export(NodePath) var obstacle_tilemap_path = null
onready var obstacle_tilemap = get_node(obstacle_tilemap_path)

var enemy_scene = load("res://enemy/Enemy.tscn")

func try_spawn(type, pos, require_grass):
	var tile = obstacle_tilemap.get_cellv(obstacle_tilemap.world_to_map(pos))
	if not require_grass or tile == TileType.TALLGRASS:
		var e = enemy_scene.instance()
		e.position = pos
		e.type = type
		add_child(e)
		return true
	return false

func is_grass(pos):
	var tile = obstacle_tilemap.get_cellv(obstacle_tilemap.world_to_map(pos))
	return tile == TileType.TALLGRASS
