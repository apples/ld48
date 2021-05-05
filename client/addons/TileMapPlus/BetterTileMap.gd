tool
extends TileMap

#signal cell_changed(tilemap, pos, tile, flip_x, flip_y, transpose, autotile_coord)

#func set_cell(x: int, y: int, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false, autotile_coord: Vector2 = Vector2(0, 0)):
	#.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	#emit_signal("cell_changed", self, Vector2(x, y), tile, flip_x, flip_y, transpose, autotile_coord)

#func set_cellv(pos: Vector2, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false):
	#.set_cellv(pos, tile, flip_x, flip_y, transpose)
	#emit_signal("cell_changed", self, pos, tile, flip_x, flip_y, transpose, Vector2(0, 0))
