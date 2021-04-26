extends Control

export(NodePath) var player_path = null
onready var player = get_node(player_path)

export(NodePath) var tilemap_path = null
onready var tilemap = get_node(tilemap_path)

onready var hearts = [
	$Hearts/Heart0,
	$Hearts/Heart1,
	$Hearts/Heart2,
	$Hearts/Heart3,
	$Hearts/Heart4,
	$Hearts/Heart5,
]

# Called when the node enters the scene tree for the first time.
func _ready():
	StrandService.connect("connected", self, "_on_StrandService_connected")
	StrandService.connect("connect_failed", self, "_on_StrandService_connect_failed")
	if StrandService.player_name != null:
		$NameLabel.text = "Connected (" + StrandService.player_name + ":" + str(StrandService.player_id) + ")"
	else:
		$NameLabel.text = "Offline"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(6):
		var has_heart = Globals.player_health >= (i + 1)
		hearts[i].visible = has_heart
	$CoordLabel.text = str(tilemap.world_to_map(player.position))

func _on_StrandService_connected(id):
	$NameLabel.text = "Connected (" + StrandService.player_name + ":" + str(StrandService.player_id) + ")"

func _on_StrandService_connect_failed(reason):
	$NameLabel.text = "Offline"
