tool
extends TileMap

export(bool) var enable_in_game = true

signal cell_changed(tilemap, pos, from_tile, to_tile, flip_x, flip_y, transpose, autotile_coord)

func update_priority_area(pos: Vector2, rng: RandomNumberGenerator = null):
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	
	var tile_id = get_cell(pos.x, pos.y)
	if tile_id == INVALID_CELL:
		return
	if tile_set.tile_get_tile_mode(tile_id) != TileSet.ATLAS_TILE:
		return
	
	var atlas_coord = tile_set.get_random_atlas_coord(tile_id, rng)
	
	var x = pos.x
	var y = pos.y
	var x_flip = is_cell_x_flipped(x, y)
	var y_flip = is_cell_y_flipped(x, y)
	var xposed = is_cell_transposed(x, y)
	set_cell(x, y, tile_id, x_flip, y_flip, xposed, atlas_coord)
	

func update_priority_region(start: Vector2, end: Vector2):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for y in range(start.y, end.y):
		for x in range(start.x, end.x):
			update_priority_area(Vector2(x, y), rng)

func set_cell(x: int, y: int, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false, autotile_coord: Vector2 = Vector2(0, 0)):
	var from_tile = get_cell(x, y)
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	_set_cell_common(Vector2(x, y), from_tile, tile, flip_x, flip_y, transpose, autotile_coord)

func set_cellv(pos: Vector2, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false):
	var from_tile = get_cellv(pos)
	.set_cellv(pos, tile, flip_x, flip_y, transpose)
	_set_cell_common(pos, from_tile, tile, flip_x, flip_y, transpose, Vector2(0, 0))

func _set_cell_common(pos: Vector2, from_tile: int, tile: int, flip_x: bool, flip_y: bool, transpose: bool, autotile_coord: Vector2):	
	if Engine.editor_hint or enable_in_game:
		# Fix to update autotile bitmasks after atlas tile placement
		if tile != INVALID_CELL:
			match tile_set.tile_get_tile_mode(tile):
				TileSet.ATLAS_TILE:
					update_bitmask_area(pos)
		
		# Emit changed signal
		emit_signal("cell_changed", self, pos, from_tile, tile, flip_x, flip_y, transpose, Vector2(0, 0))
