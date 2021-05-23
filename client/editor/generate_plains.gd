tool
extends EditorScript

func _run():
	_generate_plains(
		Vector2(1, 10), Vector2(192, 256))

enum { N, S, E, W, NE, SE, NW, SW }

var Req = AutomataSystem.Req
var DirectionalReq = AutomataSystem.DirectionalReq
var NumericReq = AutomataSystem.NumericReq
var Rule = AutomataSystem.Rule

var none_adjacent = DirectionalReq.new({
	N: TileType.NONE,
	S: TileType.NONE,
	E: TileType.NONE,
	W: TileType.NONE,
})

var any_adjacent = Req.OR([
	DirectionalReq.new({ N: TileType.TALLGRASS }),
	DirectionalReq.new({ S: TileType.TALLGRASS }),
	DirectionalReq.new({ W: TileType.TALLGRASS }),
	DirectionalReq.new({ E: TileType.TALLGRASS }),
])

var tree_adjacent = Req.OR([
	DirectionalReq.new({ N: TileType.TREETRUNK }),
	DirectionalReq.new({ S: TileType.TREETRUNK }),
	DirectionalReq.new({ W: TileType.TREETRUNK }),
	DirectionalReq.new({ E: TileType.TREETRUNK }),
])

var all_adjacent = DirectionalReq.new({
	N: TileType.TALLGRASS,
	S: TileType.TALLGRASS,
	E: TileType.TALLGRASS,
	W: TileType.TALLGRASS,
})

var seed_rules = {
	TileType.NONE: [
		# Grow grass
		
		Rule.new(TileType.TALLGRASS, 1),
		Rule.new(TileType.NONE, 25),
		
		# Grow trees
		
		Rule.new(TileType.TREETRUNK, 1),
		Rule.new(TileType.NONE, 250),
	],
}

var grow_rules = {
	TileType.NONE: [
		# Grow grass
		
		Rule.new(TileType.TALLGRASS, 1, none_adjacent),
		Rule.new(TileType.NONE, 100, none_adjacent),
		
		# Expand grass
		
		Rule.new(TileType.TALLGRASS, 1, any_adjacent),
		Rule.new(TileType.NONE, 1, any_adjacent),
		
		# Expand grass from trees
		
		Rule.new(TileType.TALLGRASS, 1, tree_adjacent),
		Rule.new(TileType.NONE, 1, tree_adjacent),
	],
}

var mow_rules = {
	TileType.TALLGRASS: [
		# Mow grass
		
		Rule.new(TileType.TALLGRASS, 2, all_adjacent),
		Rule.new(TileType.NONE, 1, all_adjacent),
	],
}

func _generate_plains(start: Vector2, end: Vector2):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	var size = end - start
	
	var automata = AutomataSystem.new(size, TileType.NONE)
	
	var rects = []
	
	print("Generating plains...")
	
	print("Applying automata rules...")
	
	automata.apply(seed_rules, rng)
	automata.apply(grow_rules, rng)
	automata.apply(grow_rules, rng)
	automata.apply(grow_rules, rng)
	automata.apply(mow_rules, rng)
	
	var whiteboard = automata.whiteboard
	
	print("Applying whiteboard to tilemap...")
	
	for y in range(size.y):
		for x in range(size.x):
			match whiteboard[y][x]:
				TileType.CLIFF:
					flr.set_cell(start.x + x, start.y + y, TileType.CLIFF)
					obst.set_cell(start.x + x, start.y + y, TileType.NONE)
				var id:
					flr.set_cell(start.x + x, start.y + y, TileType.GROUND)
					obst.set_cell(start.x + x, start.y + y, id)
	
	print("Updating bitmasks and priorities...")
	
	flr.update_bitmask_region(start, end)
	obst.update_bitmask_region(start, end)
	flr.update_priority_region(start, end)
	obst.update_priority_region(start, end)
	
	print("Done.")

