tool
extends EditorScript

var dist = 100
var xlim = 63

var num_trees = 250

func _run():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("Navigation2D/TileMapFloor")
	var obst = get_scene().get_node("Navigation2D/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	# cleanup tiles outside world
	
	for pos in flr.get_used_cells():
		if pos.x < 0 or pos.y < 0 or pos.x > xlim or pos.y > dist:
			flr.set_cellv(pos, TileType.NONE)
	for pos in obst.get_used_cells():
		if pos.x < 0 or pos.y < 0 or pos.x > xlim or pos.y > dist:
			obst.set_cellv(pos, TileType.NONE)
	
	# clear nonsense from obstacles
	
	for pos in obst.get_used_cells_by_id(TileType.GROUND):
		obst.set_cellv(pos, TileType.NONE)
	
	# world border
	
	for y in range(dist + 1):
		flr.set_cellv(Vector2(0, y), TileType.GROUND)
		flr.set_cellv(Vector2(xlim, y), TileType.GROUND)
		obst.set_cellv(Vector2(0, y), TileType.BOULDER)
		obst.set_cellv(Vector2(xlim, y), TileType.BOULDER)
	for x in range(xlim + 1):
		flr.set_cellv(Vector2(x, 0), TileType.GROUND)
		flr.set_cellv(Vector2(x, dist), TileType.GROUND)
		obst.set_cellv(Vector2(x, 0), TileType.BOULDER)
		obst.set_cellv(Vector2(x, dist), TileType.BOULDER)
	
	# move cliffs and grass to obst
	
	for pos in flr.get_used_cells_by_id(TileType.BOULDER):
		obst.set_cellv(pos, TileType.BOULDER)
		flr.set_cellv(pos, TileType.GROUND)
	
	for pos in flr.get_used_cells_by_id(TileType.CLIFF):
		obst.set_cellv(pos, TileType.CLIFF)
		flr.set_cellv(pos, TileType.GROUND)
	
	# fill floor
	
	for y in range(dist + 1):
		for x in range(xlim + 1):
			var pos = Vector2(x, y)
			if flr.get_cellv(pos) == TileType.NONE:
				flr.set_cellv(pos, TileType.GROUND)
	
	# clear canopy
	
	for pos in canopy.get_used_cells_by_id(TileType.TREETOP):
		canopy.set_cellv(pos, TileType.NONE)
	
	flr.update_bitmask_region()
	obst.update_bitmask_region()
