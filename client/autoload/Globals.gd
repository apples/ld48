extends Node

var savegame_file = "user://saved_game.cfg"

var current_day = 0
var current_time = 0
var day_length = 30
var night_killscreen = 5

var player_health = 5

func advance_day():
	current_day += 1
	var f = ConfigFile.new()
	f.load(savegame_file)
	f.set_value("calendar", "day", current_day)
	f.save(savegame_file)

func _ready():
	var f = ConfigFile.new()
	f.load(savegame_file)
	current_day = f.get_value("calendar", "day", 0) + 1
	print("Day " + str(current_day))

func _process(delta):
	current_time += delta * (5 if Input.is_key_pressed(KEY_P) else 1)

