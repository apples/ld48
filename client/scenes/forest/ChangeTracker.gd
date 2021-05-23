extends Node

signal commit_started
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

export(NodePath) var torchholder_path = null
onready var torchholder = get_node(torchholder_path)

var torch_scene = load("res://light/TorchLight.tscn")
var torches = {}

var last_tree_hit = null

func cut_grass(pos, do_commit = true):
	var did = false
	if obstacle_tilemap.get_cellv(pos) == TileType.TALLGRASS:
		print("Cutting grass at " + str(pos))
		did = true
		obstacle_tilemap.set_cellv(pos, -1)
	if did and do_commit:
		_commit_event(EventType.CUT_GRASS, pos, 1)
	return did

func cut_stickbush(pos, do_commit = true):
	var did = false
	if obstacle_tilemap.get_cellv(pos) == TileType.STICKBUSH:
		print("Cutting stickbush at " + str(pos))
		did = true
		obstacle_tilemap.set_cellv(pos, -1)
		if do_commit:
			Globals.resources[EventType.PLACE_LADDER] += 1
	if did and do_commit:
		_commit_event(EventType.CUT_STICKBUSH, pos, 1, false)
	return did

func cut_tree(pos, do_commit = true):
	var did = false
	if pos == last_tree_hit and obstacle_tilemap.get_cellv(pos) == TileType.TREETRUNK:
		print("Cutting tree at " + str(pos))
		did = true
		obstacle_tilemap.set_cellv(pos, -1)
	else:
		last_tree_hit = pos
	if did and do_commit:
		_commit_event(EventType.CUT_TREE, pos, 1, false)
	return did

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
	if did and do_commit:
		_commit_event(EventType.BERRY_BUSH, pos, 1)
	return did

func place_torch(pos, do_commit = true):
	print("Placing torch at " + str(pos))
	var t = obstacle_tilemap.get_cellv(pos)
	var did = false
	match t:
		TileType.NONE:
			obstacle_tilemap.set_cellv(pos, TileType.TORCH_OUT)
			var torch = torch_scene.instance()
			torch.position = obstacle_tilemap.map_to_world(pos) + Vector2(8, 8)
			torchholder.add_child(torch)
			torches[pos] = torch
			did = true
		TileType.TORCH_OUT, TileType.TORCH:
			obstacle_tilemap.set_cellv(pos, TileType.TORCH)
			torches[pos].add_fuel(1)
			did = true
	if did and do_commit:
		_commit_event(EventType.PLACE_TORCH, pos, 1)
	return did

func place_ladder(pos, do_commit = true):
	print("Placing ladder at " + str(pos))
	var t = tilemap.get_cellv(pos)
	var did = false
	match t:
		TileType.CLIFF:
			tilemap.set_cellv(pos, TileType.CLIFF_LADDER)
			tilemap.update_bitmask_area(pos)
			did = true
	if did and do_commit:
		_commit_event(EventType.PLACE_LADDER, pos, 1)
	return did

func commit():
	emit_signal("commit_started")
	
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
	
	# Notify server
	
	if StrandService.is_online():
		StrandService.AddPath(path, Globals.current_day, self, "_on_StrandService_AddPath_complete")
	else:
		emit_signal("commit_complete")

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
		var flr = tilemap.get_cellv(pos)
		if obs == TileType.NONE and flr == TileType.GROUND:
			var wear = wear_map[pos]
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
	
	for tile in strand_wornTiles:
		var pos = Vector2(tile[0], tile[1])
		var wear = int(tile[2])
		var obs = obstacle_tilemap.get_cellv(pos)
		var flr = tilemap.get_cellv(pos)
		if obs == TileType.NONE:
			match flr:
				TileType.FOOTPRINT:
					if wear > 1:
						tilemap.set_cellv(pos, TileType.PATH)
						tilemap.update_bitmask_area(pos)
				TileType.PATH:
					pass
				TileType.GROUND:
					if wear > 3:
						tilemap.set_cellv(pos, TileType.PATH)
						tilemap.update_bitmask_area(pos)
					elif wear > 0:
						tilemap.set_cellv(pos, TileType.FOOTPRINT)

func _ready():
	rng.randomize()

func _commit_event(type, pos, val, strand = true):
	assert(int(pos.x) == pos.x)
	assert(int(pos.y) == pos.y)
	events.append({
		"type": type,
		"where": pos,
		"value": val,
	})
	if strand:
		StrandService.AddEvent(type, val, pos.x, pos.y)

func _apply_event(type, pos, do_commit = false):
	match type:
		EventType.CUT_GRASS:
			cut_grass(pos, do_commit)
		EventType.BERRY_BUSH:
			grow_berrybush(pos, do_commit)
		EventType.PLACE_TORCH:
			place_torch(pos, do_commit)
		EventType.PLACE_LADDER:
			place_ladder(pos, do_commit)
		EventType.CUT_STICKBUSH:
			cut_stickbush(pos, do_commit)
		_:
			print("UNKNOWN EVENT " + str(type))

func _on_Timer_timeout():
	var pathpos = tilemap.world_to_map(player.position)
	path.append({ "pos": pathpos, "timestamp": Globals.current_time })

func _on_StrandService_AddPath_complete(json):
	emit_signal("commit_complete")
