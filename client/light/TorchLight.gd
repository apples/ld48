tool
extends Light2D

export(int) var fuel = 0 setget set_fuel

export(bool) var enable_canopy = true setget set_enable_canopy

func set_enable_canopy(value: bool):
	enable_canopy = value
	$CanopyLight.enabled = value

func add_fuel(amt):
	set_fuel(max(0, fuel + amt))

func set_fuel(value: int):
	fuel = value
	enabled = fuel != 0
	$CanopyLight.enabled = enable_canopy and enabled
	print("Fueled: " + str(fuel))
	print("Enabled: " + str(enabled))

# Called when the node enters the scene tree for the first time.
func _ready():
	enabled = fuel != 0
	$CanopyLight.enabled = enable_canopy and enabled
