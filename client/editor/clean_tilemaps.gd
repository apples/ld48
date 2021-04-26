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
	
	for pos in obst.get_used_cells():
		match obst.get_cellv(pos):
			TileType.GROUND, TileType.CLIFF:
				obst.set_cellv(pos, TileType.NONE)
	
	# world border
	
	for y in range(dist + 1):
		flr.set_cellv(Vector2(0, y), TileType.BOULDER)
		flr.set_cellv(Vector2(xlim, y), TileType.BOULDER)
		obst.set_cellv(Vector2(0, y), TileType.NONE)
		obst.set_cellv(Vector2(xlim, y), TileType.NONE)
	for x in range(xlim + 1):
		flr.set_cellv(Vector2(x, 0), TileType.BOULDER)
		flr.set_cellv(Vector2(x, dist), TileType.BOULDER)
		obst.set_cellv(Vector2(x, 0), TileType.NONE)
		obst.set_cellv(Vector2(x, dist), TileType.NONE)
	
	# fill floor
	
	for y in range(dist + 1):
		for x in range(xlim + 1):
			var pos = Vector2(x, y)
			if flr.get_cellv(pos) == TileType.NONE:
				flr.set_cellv(pos, TileType.GROUND)
	
	# clear tall grass
	
	for pos in obst.get_used_cells_by_id(TileType.TALLGRASS):
		obst.set_cellv(pos, TileType.NONE)
	
	# remove invalid trees
	
	for pos in obst.get_used_cells_by_id(TileType.TREETRUNK):
		match flr.get_cellv(pos):
			TileType.GROUND:
				pass
			_:
				obst.set_cellv(pos, TileType.NONE)
	
	# clear canopy
	
	for pos in canopy.get_used_cells_by_id(TileType.TREETOP):
		canopy.set_cellv(pos, TileType.NONE)
	
	
