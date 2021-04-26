extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_selected()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_selected()

func _update_selected():
	$BerryBushRect.hide()
	$TorchRect.hide()
	var sel = Globals.resource_order[Globals.selected_resource]
	$AmountLabel.text = str(Globals.resources[sel])
	match sel:
		EventType.BERRY_BUSH:
			$BerryBushRect.show()
		EventType.PLACE_TORCH:
			$TorchRect.show()
