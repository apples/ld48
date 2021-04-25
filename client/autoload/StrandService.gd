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

func AddPath():
	pass

#################
# Private Methods
#################

func _ready():
	pass

func _make_request(obj, cb):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "on_http_request_completed", [http_request, obj, cb])
	return http_request

func _post_json(path, data, obj, cb):
	var body = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	var req = _make_request(obj, cb)
	var err = req.request(server_url + path, headers, validate_domain, HTTPClient.METHOD_POST, body)
	if err != OK:
		req.queue_free()
	return err

func _save_id():
	var conf = ConfigFile.new()
	conf.set_value("player", "id", player_id)
	conf.set_value("player", "name", player_name)
	conf.save(config_file)

func on_http_request_completed(result, response_code, headers, body, http_request, obj, cb):
	http_request.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS:
		match response_code:
			200, 201:
				var json = JSON.parse(body.get_string_from_utf8())
				if json.error == OK:
					obj.call(cb, null, json.result)
				else:
					obj.call(cb, "Bad JSON", null)
			_:
				obj.call(cb, "Reponse code " + str(response_code), null)
	else:
		obj.call(cb, "Request failed (" + str(result) + ")", null)
