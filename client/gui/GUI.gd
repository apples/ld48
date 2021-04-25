extends Control

onready var hearts = [
	$Hearts/Heart0,
	$Hearts/Heart1,
	$Hearts/Heart2,
	$Hearts/Heart3,
	$Hearts/Heart4,
	$Hearts/Heart5,
]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(6):
		var has_heart = Globals.player_health >= (i + 1)
		hearts[i].visible = has_heart
