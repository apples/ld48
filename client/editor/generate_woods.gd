tool
extends EditorScript

var start = Vector2(1, 75)
var end = Vector2(127, 122)

# inner rect sizes
var rect_size_min = Vector2(5, 1)
var rect_size_max = Vector2(10, 5) # needs to be at least min * 2 + 1

func _run():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var flr = get_scene().get_node("TileMapFloor")
	var obst = get_scene().get_node("YSort/TileMapObstacles")
	var canopy = get_scene().get_node("TileMapCanopy")
	
	# account for border
	rect_size_min += Vector2(1, 1)
	rect_size_max += Vector2(1, 1)
	
	assert(rect_size_max.x >= rect_size_min.x * 2 - 1)
	assert(rect_size_max.y >= rect_size_min.y * 2 - 1)
	
	for y in range(start.y, end.y):
		for x in range(start.x, end.x):
			if obst.get_cell(x, y) != TileType.NONE:
				obst.set_cell(x, y, TileType.NONE)
	
	var rects = []
	
	# generate rects
	for y in range(start.y, end.y - rect_size_min.y - 2):
		for x in range(start.x, end.x):
			# check if no rect
			if obst.get_cell(x, y) == TileType.NONE:
				# generate rect
				var rect = Rect2(x, y, 0, 0)
				
				var size_min = Vector2(rect_size_min.x, rect_size_min.y)
				var size_max = Vector2(rect_size_max.x + rect_size_min.x, rect_size_max.y)
				
				# check max width
				for xx in range(rect_size_max.x + rect_size_min.x):
					if obst.get_cell(x + xx, y) != TileType.NONE:
						size_max.x = xx
						break
				
				# check for edge cases
				var mx = min(rect_size_max.x, size_max.x - rect_size_min.x)
				if mx < rect_size_min.x:
					size_min.x = size_max.x
				else:
					size_max.x = mx
				
				# roll dice
				rect.size.x = rng.randi_range(size_min.x, size_max.x)
				rect.size.y = rng.randi_range(size_min.y, size_max.y)
				
				# mark territory
				for yy in range(rect.size.y):
					for xx in range(rect.size.x):
						if xx != 0 and yy != 0:
							obst.set_cell(x + xx, y + yy, TileType.CLIFF)
						else:
							obst.set_cell(x + xx, y + yy, TileType.BOULDER)
				
				rects.append(rect)
	
	for rect in rects:
		for yy in range(rect.size.y):
			for xx in range(rect.size.x):
				if xx != 0 and yy != 0:
					obst.set_cellv(rect.position + Vector2(xx, yy), TileType.NONE)
	
	
	
	
