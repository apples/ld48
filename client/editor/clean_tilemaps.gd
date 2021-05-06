tool
extends EditorScript

func _run():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("Navigation2D/TileMapFloor")
	var obst = get_scene().get_node("Navigation2D/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	flr.update_bitmask_region()
	obst.update_bitmask_region()
