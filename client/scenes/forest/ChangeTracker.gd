extends Node

export(NodePath) var tilemap_node_path = null
onready var tilemap = get_node(tilemap_node_path)

export(NodePath) var obstacle_tilemap_node_path = null
onready var obstacle_tilemap = get_node(obstacle_tilemap_node_path)

export(NodePath) var player_node_path = null
onready var player = get_node(player_node_path)

enum Action {
	CUT_GRASS,
	BERRY_BUSH
}

var path = []
var actions = []

var all_actions = []
var day_paths = []

var rng = RandomNumberGenerator.new()

func cut_grass(pos, do_commit = true):
	if obstacle_tilemap.get_cellv(pos) == TileType.TALLGRASS:
		print("Cutting grass at " + str(pos))
		obstacle_tilemap.set_cellv(pos, -1)
	if do_commit:
		actions.append({
			"type": Action.CUT_GRASS,
			"where": pos,
			"decay": 0.25,
		})

func grow_berrybush(pos, do_commit = true):
	print("Growing berrybush at " + str(pos))
	var t = obstacle_tilemap.get_cellv(pos)
	match t:
		TileType.NONE:
			obstacle_tilemap.set_cellv(pos, TileType.BERRYBUSH0)
		TileType.BERRYBUSH0, TileType.BERRYBUSH1, TileType.BERRYBUSH2, TileType.BERRYBUSH3:
			obstacle_tilemap.set_cellv(pos, t + 1)
	if do_commit:
		actions.append({
			"type": Action.BERRY_BUSH,
			"where": pos,
			"decay": 0,
		})

func commit():
	var f = ConfigFile.new()
	f.load(Globals.savegame_file)
	
	all_actions += actions
	
	var new_all = []
	for act in all_actions:
		if rng.randf() >= act["decay"]:
			new_all.append(act)
	all_actions = new_all
	f.set_value("world", "actions", all_actions)
	
	day_paths.append(path)
	var dps = day_paths.size()
	if dps > 10:
		day_paths = day_paths.slice(dps - 10, dps - 1)
	f.set_value("world", "paths", day_paths)
	
	f.save(Globals.savegame_file)

func load_and_replay_all(floor_map, obstacle_map):
	var f = ConfigFile.new()
	f.load(Globals.savegame_file)
	all_actions = f.get_value("world", "actions", [])
	day_paths = f.get_value("world", "paths", [])
	
	for act in all_actions:
		match act["type"]:
			Action.CUT_GRASS:
				cut_grass(act["where"], false)
			Action.BERRY_BUSH:
				grow_berrybush(act["where"], false)
	
	var wear_map = {}
	var max_wear = 0
	
	for p in day_paths:
		for step in p:
			var c = wear_map.get(step, 0) + 1
			max_wear = max(max_wear, c)
			wear_map[step] = c
	
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
				

func _ready():
	rng.randomize()

func _on_Timer_timeout():
	var pathpos = tilemap.world_to_map(player.position)
	path.append(pathpos)
