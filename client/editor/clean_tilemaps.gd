tool
extends EditorScript

func _run():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	for pos in obst.get_used_cells_by_id(TileType.SWAMP_WATER):
		var atc = obst.get_cell_autotile_coord(pos.x, pos.y)
		obst.set_cellv(pos, TileType.NONE)
		flr.set_cell(pos.x, pos.y, TileType.SWAMP_WATER, false, false, false, atc)
	
	flr.update_bitmask_region()
	obst.update_bitmask_region()
	canopy.update_bitmask_region()
