extends Label


var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	var c = int(time * 2) % 3 + 1
	var dots = ""
	for i in range(c):
		dots += "."
	text = "Connecting" + dots
