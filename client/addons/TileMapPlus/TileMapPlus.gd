tool
extends TileMap

export(bool) var enable_in_game = true

signal cell_changed(tilemap, pos, tile, flip_x, flip_y, transpose, autotile_coord)

func set_cell(x: int, y: int, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false, autotile_coord: Vector2 = Vector2(0, 0)):
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	_set_cell_common(Vector2(x, y), tile, flip_x, flip_y, transpose, autotile_coord)
	# Emit changed signal
	if Engine.editor_hint or enable_in_game:
		emit_signal("cell_changed", self, Vector2(x, y), tile, flip_x, flip_y, transpose, autotile_coord)

func set_cellv(pos: Vector2, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false):
	.set_cellv(pos, tile, flip_x, flip_y, transpose)
	if Engine.editor_hint or enable_in_game:
		emit_signal("cell_changed", self, pos, tile, flip_x, flip_y, transpose, Vector2(0, 0))

func _set_cell_common(pos: Vector2, tile: int, flip_x: bool, flip_y: bool, transpose: bool, autotile_coord: Vector2):	
	if Engine.editor_hint or enable_in_game:
		# Fix to update autotile bitmasks after atlas tile placement
		if tile != INVALID_CELL:
			match tile_set.tile_get_tile_mode(tile):
				TileSet.ATLAS_TILE:
					update_bitmask_area(pos)
		
		# Emit changed signal
		emit_signal("cell_changed", self, pos, tile, flip_x, flip_y, transpose, Vector2(0, 0))
