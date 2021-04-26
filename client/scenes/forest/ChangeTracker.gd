extends Node

signal commit_complete

export(NodePath) var tilemap_node_path = null
onready var tilemap = get_node(tilemap_node_path)

export(NodePath) var obstacle_tilemap_node_path = null
onready var obstacle_tilemap = get_node(obstacle_tilemap_node_path)

export(NodePath) var player_node_path = null
onready var player = get_node(player_node_path)

var path = []
var events = []

var all_events = []
var day_paths = []

var rng = RandomNumberGenerator.new()

func cut_grass(pos, do_commit = true):
	if obstacle_tilemap.get_cellv(pos) == TileType.TALLGRASS:
		print("Cutting grass at " + str(pos))
		obstacle_tilemap.set_cellv(pos, -1)
	if do_commit:
		_commit_event(EventType.CUT_GRASS, pos, 1)

func grow_berrybush(pos, do_commit = true):
	print("Growing berrybush at " + str(pos))
	var t = obstacle_tilemap.get_cellv(pos)
	var did = false
	match t:
		TileType.NONE:
			obstacle_tilemap.set_cellv(pos, TileType.BERRYBUSH0)
			did = true
		TileType.BERRYBUSH0, TileType.BERRYBUSH1, TileType.BERRYBUSH2, TileType.BERRYBUSH3:
			obstacle_tilemap.set_cellv(pos, t + 1)
			did = true
	if do_commit:
		_commit_event(EventType.BERRY_BUSH, pos, 1)

func commit():
	
	# Notify server
	
	StrandService.AddPath(path, Globals.current_day, self, "_on_StrandService_AddPath_complete")
	
	# Update save file
	
	var f = ConfigFile.new()
	f.load(Globals.savegame_file)
	
	all_events += events
	
	var new_all = []
	for act in all_events:
		if rng.randf() >= EventType.get_decay(act["type"]):
			new_all.append(act)
	all_events = new_all
	f.set_value("world", "events", all_events)
	
	day_paths.append(path)
	var dps = day_paths.size()
	if dps > 10:
		day_paths = day_paths.slice(dps - 10, dps - 1)
	f.set_value("world", "paths", day_paths)
	
	f.save(Globals.savegame_file)

func load_and_replay_all(floor_map, obstacle_map):
	var f = ConfigFile.new()
	f.load(Globals.savegame_file)
	all_events = f.get_value("world", "events", [])
	day_paths = f.get_value("world", "paths", [])
	
	for act in all_events:
		_apply_event(act["type"], act["where"])
	
	var wear_map = {}
	var max_wear = 0
	
	for p in day_paths:
		for step in p:
			var pos = step["pos"]
			var c = wear_map.get(pos, 0) + 1
			max_wear = max(max_wear, c)
			wear_map[pos] = c
	
	for pos in wear_map:
		var obs = obstacle_tilemap.get_cellv(pos)
		if obs == TileType.NONE:
			var wear = wear_map[pos]
			print(str(pos) + ": " + str(wear))
			if wear > 3:
				tilemap.set_cellv(pos, TileType.PATH)
				tilemap.update_bitmask_area(pos)
			elif wear > 0:
				tilemap.set_cellv(pos, TileType.FOOTPRINT)

func apply_strand_data(strand_data):
	print("apply_strand_data " + str(strand_data))
	var strand_events = strand_data["events"]
	var strand_wornTiles = strand_data["wornTiles"]
	
	for ev in strand_events:
		var pos = Vector2(ev[0], ev[1])
		var type = int(ev[2])
		var val = int(ev[3])
		
		if val > 0:
			for i in range(val):
				_apply_event(type, pos)
		else:
			print("Aaaah! apply_strand_data REEEEEEEE")
	
	#for tile in strand_wornTiles:
	

func _ready():
	rng.randomize()

func _commit_event(type, pos, val):
	assert(int(pos.x) == pos.x)
	assert(int(pos.y) == pos.y)
	events.append({
		"type": type,
		"where": pos,
		"value": val,
	})
	StrandService.AddEvent(type, val, pos.x, pos.y)

func _apply_event(type, pos):
	match type:
		EventType.CUT_GRASS:
			cut_grass(pos, false)
		EventType.BERRY_BUSH:
			grow_berrybush(pos, false)
		_:
			print("UNKNOWN EVENT " + str(type))

func _on_Timer_timeout():
	var pathpos = tilemap.world_to_map(player.position)
	path.append({ "pos": pathpos, "timestamp": Globals.current_time })

func _on_StrandService_AddPath_complete(json):
	emit_signal("commit_complete")
