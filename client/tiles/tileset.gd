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
