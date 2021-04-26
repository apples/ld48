tool
extends EditorScript

func _run():
	var obst = get_scene().get_node("Navigation2D/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	for pos in canopy.get_used_cells_by_id(TileType.TREETOP):
		canopy.set_cellv(pos, TileType.NONE)
	
	for pos in obst.get_used_cells_by_id(TileType.TREETRUNK):
		canopy.set_cellv(pos + Vector2(0, -1), TileType.TREETOP)
