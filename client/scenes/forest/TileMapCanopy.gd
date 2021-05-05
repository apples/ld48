tool
extends "res://addons/TileMapPlus/TileMapPlus.gd"

export(bool) var sync_trunks = true

func _on_TileMapObstacles_cell_changed(tilemap, pos, from_tile, to_tile, flip_x, flip_y, transpose, autotile_coord):
	if sync_trunks:
		var toppos = pos + Vector2(0, -1)
		if to_tile == TileType.TREETRUNK:
			match get_cellv(toppos):
				TileType.NONE:
					set_cellv(toppos, TileType.TREETOP, flip_x, flip_y, transpose)
					update_bitmask_area(toppos)
		elif from_tile == TileType.TREETRUNK:
			match get_cellv(toppos):
				TileType.TREETOP:
					set_cellv(toppos, TileType.NONE)
					update_bitmask_area(toppos)
