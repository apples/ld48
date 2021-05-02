tool
extends EditorScript

var dist = 100
var xlim = 63

var num_trees = 250

func _run():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	# restore canopy
	
	for pos in canopy.get_used_cells_by_id(TileType.TREETOP):
		canopy.set_cellv(pos, TileType.NONE)
	
	for pos in obst.get_used_cells_by_id(TileType.TREETRUNK):
		canopy.set_cellv(pos + Vector2(0, -1), TileType.TREETOP)
	
	canopy.update_bitmask_region()
