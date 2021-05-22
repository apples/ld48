tool
extends EditorScript

func _run():
	_generate_woods(
		Vector2(1, 65), Vector2(127, 74),
		Vector2(12, 10), Vector2(15, 15),
		40)
	_generate_woods(
		Vector2(1, 75), Vector2(127, 100),
		Vector2(8, 5), Vector2(15, 15),
		40)
	_generate_woods(
		Vector2(1, 101), Vector2(127, 126),
		Vector2(5, 3), Vector2(10, 10),
		40)

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

var clear_NS = DirectionalReq.new({
	N: TileType.NONE,
	S: TileType.NONE,
})

var on_edge = Req.AND([
	NumericReq.new(TileType.NONE, 5),
	Req.OR([
		DirectionalReq.new({
			N: TileType.NONE,
			NE: TileType.NONE,
			E: TileType.NONE,
			SE: TileType.NONE,
			S: TileType.NONE,
		}),
		DirectionalReq.new({
			N: TileType.NONE,
			NW: TileType.NONE,
			W: TileType.NONE,
			SW: TileType.NONE,
			S: TileType.NONE,
		}),
		DirectionalReq.new({
			W: TileType.NONE,
			NW: TileType.NONE,
			N: TileType.NONE,
			NE: TileType.NONE,
			E: TileType.NONE,
		}),
		DirectionalReq.new({
			W: TileType.NONE,
			SW: TileType.NONE,
			S: TileType.NONE,
			SE: TileType.NONE,
			E: TileType.NONE,
		}),
	]),
])

var on_corner = Req.AND([
	NumericReq.new(TileType.NONE, 3),
	Req.OR([
		DirectionalReq.new({
			N: TileType.NONE,
			NE: TileType.NONE,
			E: TileType.NONE,
		}),
		DirectionalReq.new({
			N: TileType.NONE,
			NW: TileType.NONE,
			W: TileType.NONE,
		}),
		DirectionalReq.new({
			S: TileType.NONE,
			SE: TileType.NONE,
			E: TileType.NONE,
		}),
		DirectionalReq.new({
			S: TileType.NONE,
			SW: TileType.NONE,
			W: TileType.NONE,
		}),
	]),
])

var part_of_big_boulder = Req.OR([
	DirectionalReq.new({
		N: TileType.BOULDER,
		NE: TileType.BOULDER,
		E: TileType.BOULDER,
	}),
	DirectionalReq.new({
		N: TileType.BOULDER,
		NW: TileType.BOULDER,
		W: TileType.BOULDER,
	}),
	DirectionalReq.new({
		S: TileType.BOULDER,
		SE: TileType.BOULDER,
		E: TileType.BOULDER,
	}),
	DirectionalReq.new({
		S: TileType.BOULDER,
		SW: TileType.BOULDER,
		W: TileType.BOULDER,
	}),
])

var automata_rules = {
	TileType.NONE: [
		# Random trees in clearings
		
		Rule.new(TileType.TREETRUNK, 1, none_adjacent),
		Rule.new(TileType.NONE, 10, none_adjacent),
		
		# Random grass on edges
		
		Rule.new(TileType.TALLGRASS, 1, on_edge),
		Rule.new(TileType.NONE, 2, on_edge),
		
		# Fluff corners
		
		Rule.new(TileType.TREETRUNK, 2, on_corner),
		Rule.new(TileType.NONE, 1, on_corner),
	],
	TileType.TREETRUNK: [
		# Convert tree lines to cliffs
		
		Rule.new(TileType.CLIFF, 1, Req.AND([
			clear_NS,
			NumericReq.new(TileType.TREETRUNK, 1, 6),
		])),
		
		# Cut random trees
		
		Rule.new(TileType.NONE, 1, Req.AND([
			Req.NOT(clear_NS),
			NumericReq.new(TileType.TREETRUNK, 2, 8),
		])),
		Rule.new(TileType.TREETRUNK, 2, Req.AND([
			Req.NOT(clear_NS),
			NumericReq.new(TileType.TREETRUNK, 2, 8),
		])),
	],
	TileType.BOULDER: [
		# Break random boulders
		
		Rule.new(TileType.BOULDER, 4, NumericReq.new(TileType.BOULDER, 2, 8)),
		Rule.new(TileType.NONE, 1, NumericReq.new(TileType.BOULDER, 2, 8)),
		Rule.new(TileType.NONE, 1, DirectionalReq.new({
			N: TileType.BOULDER,
			S: TileType.BOULDER,
			E: TileType.BOULDER,
			W: TileType.BOULDER,
		})),
	],
}

var cleanup_rules = {
	TileType.CLIFF: [
		# Replace weird cliffs
		
		Rule.new(TileType.BOULDER, 1, Req.OR([
			DirectionalReq.new({ N: TileType.BOULDER }),
			DirectionalReq.new({ S: TileType.BOULDER }),
		])),
	],
	TileType.BOULDER: [
		# Replace weird boulders
		
		Rule.new(TileType.TREETRUNK, 1, Req.AND([
			Req.OR([
				DirectionalReq.new({ N: TileType.BOULDER }),
				DirectionalReq.new({ S: TileType.BOULDER }),
			]),
			Req.OR([
				DirectionalReq.new({ E: TileType.CLIFF }),
				DirectionalReq.new({ W: TileType.CLIFF }),
			]),
		])),
		
		# Replace random small boulders with trees
		
		Rule.new(TileType.TREETRUNK, 1, Req.NOT(part_of_big_boulder)),
		Rule.new(TileType.BOULDER, 3, Req.NOT(part_of_big_boulder)),
	],
	TileType.NONE: [
		# Pad out tree lines
		
		Rule.new(TileType.TREETRUNK, 1, DirectionalReq.new({
			SW: TileType.TREETRUNK,
			S: TileType.TREETRUNK,
		})),
		Rule.new(TileType.TREETRUNK, 1, DirectionalReq.new({
			S: TileType.TREETRUNK,
			SE: TileType.TREETRUNK,
		})),
	],
	TileType.TREETRUNK: [
		# Thin out tree lines against walls
		
		Rule.new(TileType.TREETRUNK, 1, Req.AND([
			DirectionalReq.new({
				W: TileType.TREETRUNK,
				E: TileType.TREETRUNK,
			}),
			Req.NOT(DirectionalReq.new({
				N: TileType.NONE,
			})),
		])),
		Rule.new(TileType.NONE, 1, Req.AND([
			DirectionalReq.new({
				W: TileType.TREETRUNK,
				E: TileType.TREETRUNK,
			}),
			Req.NOT(DirectionalReq.new({
				N: TileType.NONE,
			})),
		])),
	],
}

func _generate_woods(start: Vector2, end: Vector2, rect_size_min: Vector2, rect_size_max: Vector2, max_attempts: int):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	assert(rect_size_max.x >= rect_size_min.x * 2 - 1)
	assert(rect_size_max.y >= rect_size_min.y * 2 - 1)
	
	var size = end - start
	
	var automata = AutomataSystem.new(size, TileType.BOULDER)
	var whiteboard = automata.whiteboard
	
	var rects = []
	
	var failed_attempts = 0
	
	print("Generating woods...")
	
	# generate rects
	while true:
		if failed_attempts >= max_attempts:
			break
		
		var x = rng.randi_range(0, size.x - 1)
		var y = rng.randi_range(0, size.y - rect_size_min.y)
		
		# check if no rect
		if whiteboard[y][x] == TileType.BOULDER:
			var size_min = Vector2(rect_size_min.x, rect_size_min.y)
			var size_max = Vector2(min(rect_size_max.x, size.x - x), min(rect_size_max.y, size.y - y))
			
			# calculate max width
			for xx in range(size_max.x):
				if whiteboard[y][x + xx] != TileType.BOULDER:
					size_max.x = xx
					break
			
			# calculate max height
			for yy in range(size_max.y):
				var found = false
				for xx in range(size_max.x):
					assert(y + yy < size.y)
					assert(x + xx < size.x)
					if whiteboard[y + yy][x + xx] != TileType.BOULDER:
						size_max.y = yy
						found = true
						break
				if found:
					break
			
			# check failure
			if size_max.x < rect_size_min.x or size_max.y < rect_size_min.y:
				failed_attempts += 1
				continue
			else:
				failed_attempts = 0
			
			# generate rect
			var rect = Rect2(x, y, 0, 0)
			
			# roll dice
			rect.size.x = rng.randi_range(size_min.x, size_max.x)
			rect.size.y = rng.randi_range(size_min.y, size_max.y)
			
			# mark territory
			for yy in range(rect.size.y):
				for xx in range(rect.size.x):
					if yy == 0:
						whiteboard[y + yy][x + xx] = TileType.TREETRUNK
					else:
						whiteboard[y + yy][x + xx] = TileType.NONE
			
			rects.append(rect)
	
	print("Generated ", rects.size(), " clearings.")
	
	print("Applying automata rules...")
	
	automata.apply(automata_rules, rng)
	automata.apply(cleanup_rules, rng)
	
	whiteboard = automata.whiteboard
	
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




