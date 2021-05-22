tool
extends TileSet

var binds = {
	TileType.CLIFF: [TileType.CLIFF_LADDER],
	TileType.CLIFF_LADDER: [TileType.CLIFF],
}

func _is_tile_bound(a, b):
	if a in binds:
		return b in binds[a]
	return false

func get_random_atlas_coord(id: int, rng: RandomNumberGenerator = null):
	# Need an RNG
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	
	# Only care about ATLAS tiles
	if tile_get_tile_mode(id) != ATLAS_TILE:
		return Vector2(0, 0)
	
	# Calculate atlas size measured in tiles
	var rect = tile_get_region(id)
	var tile_size = autotile_get_size(id)
	var atlas_size = rect.size / tile_size
	
	# Create random choice
	var chooser = RandomChoice.new()
	
	for r in range(atlas_size.y):
		for c in range(atlas_size.x):
			var coord = Vector2(c, r)
			chooser.add(coord, autotile_get_subtile_priority(id, coord))
	
	if chooser.total_priority == 0:
		return Vector2(0, 0)
	
	return chooser.choose(rng)
