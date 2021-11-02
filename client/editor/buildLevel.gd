tool
extends EditorScript

var num_trees = 250

func _run():
#	print('No longer needed!')
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
#	var canopy = get_scene().get_node("TileMapCanopy")

#	for pos in flr.get_used_cells_by_id(TileType.GROUND):
#		if pos.x < 2049:#flr.get_cellv(pos):
#			flr.set_cellv(pos, TileType.GROUND)

	for pos in obst.get_used_cells_by_id(TileType.TREETRUNK):
		if pos.x < 0:#flr.get_cellv(pos):
			obst.set_cellv(Vector2(pos.x, pos.y + 1), TileType.TREETOP)

#	for pos in obst.get_used_cells_by_id(TileType.TREETRUNK):
#		obst.set_cellv(pos + Vector2(0, -1), TileType.TREETOP)

#	canopy.update_bitmask_region()
