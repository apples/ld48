extends Node

var savegame_file = "user://saved_game.cfg"

var current_day = 0
var current_time = 0
var day_length = 30
var night_killscreen = 5

var player_health = 5
var resource_defaults = {
	EventType.BERRY_BUSH: 1,
	EventType.PLACE_TORCH: 4,
	EventType.PLACE_LADDER: 1,
}
var resources = {}
var resource_order = [
	EventType.PLACE_TORCH,
	EventType.BERRY_BUSH,
	EventType.PLACE_LADDER,
]
var selected_resource = 0

var strand_data = null

func reset_player(sleeping):
	current_time = 0
	player_health = 6 if sleeping else 5
	for k in resource_defaults:
		resources[k] = resource_defaults[k]
	selected_resource = 0

func advance_day():
	current_day += 1
	var f = ConfigFile.new()
	f.load(savegame_file)
	f.set_value("calendar", "day", current_day)
	f.save(savegame_file)

func save_strand():
	assert(strand_data != null)
	var f = ConfigFile.new()
	f.load(savegame_file)
	f.set_value("strand", "current", strand_data)
	f.save(savegame_file)

func _ready():
	var f = ConfigFile.new()
	f.load(savegame_file)
	current_day = f.get_value("calendar", "day", 0) + 1
	strand_data = f.get_value("strand", "current", null)
	
	reset_player(false)
	print("Day " + str(current_day))

func _process(delta):
	current_time += delta * (5 if Input.is_key_pressed(KEY_P) else 1)

