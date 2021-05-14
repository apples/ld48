tool
extends EditorScript

var start = 65
var amt = 60

func _run():
	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	var prev_sync = canopy.sync_trunks
	canopy.sync_trunks = false
	
	_move_tilemap(flr)
	_move_tilemap(obst)
	_move_tilemap(canopy)
	
	canopy.sync_trunks = prev_sync
	
	var forest_enemies = get_scene().get_node("YSort/EnemyHolderForest").get_children()
	var swamp_enemies = get_scene().get_node("YSort/EnemyHolderSwamp").get_children()
	
	var worldcoord = flr.to_global(flr.map_to_world(Vector2(0, start)))
	
	for e in forest_enemies:
		if e.to_global(Vector2(0, 0)).y >= worldcoord.y:
			e.position.y += worldcoord.y
	for e in swamp_enemies:
		if e.to_global(Vector2(0, 0)).y >= worldcoord.y:
			e.position.y += worldcoord.y

func _move_tilemap(map):
	var rect = map.get_used_rect()
	for y in range(rect.end.y - 1, start - 1, -1):
		for x in range(rect.position.x, rect.end.x):
			map.set_cell(x, y + amt, map.get_cell(x, y))
			map.set_cell(x, y, TileMap.INVALID_CELL)
