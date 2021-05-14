extends Control

export(NodePath) var player_path = null
onready var player = get_node(player_path)

export(NodePath) var tilemap_path = null
onready var tilemap = get_node(tilemap_path)

#var player_goal = 100

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
	_update_hearts(Globals.player_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_hearts(Globals.player_health)
	
	var stamina = player.stamina
	$CoordLabel.text = str(stamina)
	$PlayerPos.margin_top = 520 - (stamina / player.max_stamina) * (520 - 34)
	$PlayerPos.margin_bottom = $PlayerPos.margin_top + 20

func _update_hearts(value):
	for i in range(6):
		var has_heart = value >= (i + 1)
		hearts[i].visible = has_heart

func _on_StrandService_connected(id):
	$NameLabel.text = "Connected (" + StrandService.player_name + ":" + str(StrandService.player_id) + ")"

func _on_StrandService_connect_failed(reason):
	$NameLabel.text = "Offline"
