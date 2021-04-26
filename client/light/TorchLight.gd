extends Light2D

export(int) var fuel = 0

func add_fuel(amt):
	fuel = max(0, fuel + amt)
	enabled = fuel != 0
	$CanopyLight.enabled = enabled
	print("Fueled: " + str(fuel))
	print("Enabled: " + str(enabled))

# Called when the node enters the scene tree for the first time.
func _ready():
	enabled = fuel != 0
	$CanopyLight.enabled = enabled
