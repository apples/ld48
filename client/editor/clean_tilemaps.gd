tool
extends EditorScript

func _run():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	flr.update_bitmask_region()
	obst.update_bitmask_region()
	canopy.update_bitmask_region()
