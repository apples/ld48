extends Area2D


func _on_SwampMazeArea_body_entered(body):
	if body.has_method("enable_canopy_mask"):
		body.enable_canopy_mask()


func _on_SwampMazeArea_body_exited(body):
	if body.has_method("disable_canopy_mask"):
		body.disable_canopy_mask()
