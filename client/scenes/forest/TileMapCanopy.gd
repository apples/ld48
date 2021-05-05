tool
extends "res://addons/TileMapPlus/TileMapPlus.gd"


func _on_TileMapObstacles_cell_changed(tilemap, pos, tile, flip_x, flip_y, transpose, autotile_coord):
	var toppos = pos + Vector2(0, -1)
	match tile:
		TileType.TREETRUNK:
			match get_cellv(toppos):
				TileType.NONE:
					set_cellv(toppos, TileType.TREETOP, flip_x, flip_y, transpose)
					update_bitmask_area(toppos)
		_:
			match get_cellv(toppos):
				TileType.TREETOP:
					set_cellv(toppos, TileType.NONE)
					update_bitmask_area(toppos)
