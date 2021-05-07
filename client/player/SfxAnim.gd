tool
extends AudioStreamPlayer


var bloops = [
	load("res://sfx/bloop1.wav"),
	load("res://sfx/bloop2.wav"),
	load("res://sfx/bloop3.wav"),
]

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func play_random_bloop():
	print("hi")
	stream = bloops[rng.randi_range(0, 2)]
	play()
