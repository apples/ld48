extends Node

signal connected(id)
signal connect_failed(reason)

var config_file = "user://strand.cfg"
var server_url = "https://localhost:5001/api"

const login_scene_path = "res://scenes/login/LoginScreen.tscn"

var world_id = 1
var zone_id = 1
var player_id = null
var player_name = null

var connecting = false

var validate_domain = false

################
# Client Methods
################

func login():
	connecting = true
	if player_id == null:
		var conf = ConfigFile.new()
		var err = conf.load(config_file)
		if err == OK:
			if conf.has_section_key("player", "id") and conf.has_section_key("player", "name"):
				player_id = conf.get_value("player", "id")
				player_name = conf.get_value("player", "name")
				VerifyPlayer(player_id, player_name)
		if player_id == null:
			get_tree().change_scene(login_scene_path)

####################
# Server API Methods
####################

func NewPlayer(name):
	var err = _post_json("/World/NewPlayer", { "name": name }, self, "_on_NewPlayer_completed")
	if err != OK:
		emit_signal("connect_failed", "Request error: " + str(err))

func _on_NewPlayer_completed(error_reason, json):
	connecting = false
	if error_reason == null:
		player_id = json["playerID"]
		player_name = json["name"]
		print("Saving as new player " + player_name)
		_save_id()
		emit_signal("connected", player_id)
	else:
		emit_signal("connect_failed", error_reason)

func VerifyPlayer(playerid, name):
	var err = _post_json("/World/VerifyPlayer", { "name": name, "playerid": playerid }, self, "_on_VerifyPlayer_completed")
	if err != OK:
		emit_signal("connect_failed", "Request error: " + str(err))

func _on_VerifyPlayer_completed(error_reason, json):
	connecting = false
	if error_reason == null:
		if not json["valid"]:
			print("Player " + str(player_name) + " was invalid for id " + str(player_id))
			player_name = null
			player_id = null
			get_tree().change_scene(login_scene_path)
		else:
			print("Player " + str(player_name) + " is valid!")
			emit_signal("connected", player_id)
	else:
		emit_signal("connect_failed", error_reason)

func AddPath(path, day, obj, cb):
	if player_id == null:
		return
	var tiles = []
	for step in path:
		var pos = step["pos"]
		tiles.append([pos.x, pos.y, step["timestamp"]])
	var data = {
		"worldID": world_id,
		"zoneID": zone_id,
		"playerID": player_id,
		"day": day,
		"tiles": tiles,
	}
	var err = _post_json("/World/AddPath", data, self, "_on_AddPath_completed", [obj, cb])
	if err != OK:
		emit_signal("connect_failed", "Request error: " + str(err))

func _on_AddPath_completed(error_reason, json, extra):
	if error_reason == null:
		print(json)
		extra[0].call(extra[1], json)
	else:
		extra[0].call(extra[1], null)
		emit_signal("connect_failed", error_reason)

func AddEvent(eventType, eventValue, tileX, tileY):
	if player_id == null:
		return
	var data = {
		"playerID": player_id,
		"eventType": eventType,
		"eventValue": eventValue,
		"tileX": tileX,
		"tileY": tileY,
	}
	var err = _post_json("/World/AddEvent", data, self, "_on_AddEvent_completed")
	if err != OK:
		emit_signal("connect_failed", "Request error: " + str(err))

func _on_AddEvent_completed(error_reason, json):
	if error_reason == null:
		pass
	else:
		emit_signal("connect_failed", error_reason)

func EndDay(day, obj, cb):
	if player_id == null:
		return
	var data = {
		"worldID": world_id,
		"zoneID": zone_id,
		"playerID": player_id,
		"day": day,
	}
	var err = _post_json("/World/EndDay", data, self, "_on_EndDay_completed", [obj, cb])
	if err != OK:
		emit_signal("connect_failed", "Request error: " + str(err))

func _on_EndDay_completed(error_reason, json, extra):
	if error_reason == null:
		print("EndDay!!!")
		print(json)
		extra[0].call(extra[1], json)
	else:
		extra[0].call(extra[1], null)
		emit_signal("connect_failed", error_reason)

#################
# Private Methods
#################

func _ready():
	pass

func _make_request(obj, cb, path, extra):
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	http_request.connect("request_completed", self, "on_http_request_completed", [http_request, obj, cb, path, extra])
	return http_request

func _post_json(path, data, obj, cb, extra = null):
	var body = JSON.print(data)
	print(path + " << " + body)
	var headers = ["Content-Type: application/json"]
	var req = _make_request(obj, cb, path, extra)
	var err = req.request(server_url + path, headers, validate_domain, HTTPClient.METHOD_POST, body)
	if err != OK:
		req.queue_free()
	return err

func _save_id():
	var conf = ConfigFile.new()
	conf.set_value("player", "id", player_id)
	conf.set_value("player", "name", player_name)
	conf.save(config_file)

func on_http_request_completed(result, response_code, headers, body, http_request, obj, cb, path, extra):
	http_request.queue_free()
	var error = null
	var data = null
	if result == HTTPRequest.RESULT_SUCCESS:
		match response_code:
			200, 201:
				var bodystr = body.get_string_from_utf8()
				print(path + " >> " + bodystr)
				var json = JSON.parse(bodystr)
				if json.error == OK:
					data = json.result
				else:
					error = "Bad JSON"
			_:
				print(path + " >> ERROR " + str(response_code))
				error = "Reponse code " + str(response_code)
	else:
		error = "Request failed (" + str(result) + ")"
		print(error)
	
	if extra != null:
		obj.call(cb, error, data, extra)
	else:
		obj.call(cb, error, data)
