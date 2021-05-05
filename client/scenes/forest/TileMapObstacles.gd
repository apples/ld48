tool
extends TileMap

export(bool) var enable_canopy = true

export(NodePath) var canopy_path = null
onready var canopy_tilemap: TileMap = get_node(canopy_path)

func set_cell(x: int, y: int, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false, autotile_coord: Vector2 = Vector2(0, 0)):
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	_do_canopy(x, y, tile, flip_x, flip_y, transpose, autotile_coord)

func set_cellv(pos: Vector2, tile: int, flip_x: bool = false, flip_y: bool = false, transpose: bool = false):
	set_cell(pos.x, pos.y, tile, flip_x, flip_y, transpose)
