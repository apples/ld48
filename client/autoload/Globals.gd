extends Node

var current_time = 0
var day_length = 30
var night_killscreen = 5

func _ready():
	pass # Replace with function body.

func _process(delta):
	current_time += delta * (5 if Input.is_key_pressed(KEY_P) else 1)
	
