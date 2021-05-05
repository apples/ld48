tool
extends Light2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		texture_scale = 0.01
