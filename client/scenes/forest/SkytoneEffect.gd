extends CanvasModulate

var skytone: Image = load("res://scenes/forest/skytone.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = Globals.current_time / Globals.day_length
	skytone.lock()
	var w = skytone.get_width()
	var tone = skytone.get_pixel(clamp(t * w, 0, w - 1), 0)
	skytone.unlock()
	color = tone
