tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TileMapPlus", "TileMap", preload("BetterTileMap.gd"), preload("BetterTileMap.svg"))


func _exit_tree():
	remove_custom_type("TileMapPlus")
