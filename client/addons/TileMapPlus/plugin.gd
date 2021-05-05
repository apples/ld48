tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TileMapPlus", "TileMap", preload("TileMapPlus.gd"), preload("TileMapPlus.svg"))


func _exit_tree():
	remove_custom_type("TileMapPlus")
