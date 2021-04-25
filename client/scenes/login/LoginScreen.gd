extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_LoginButton_pressed():
	if $Name.text.length() > 0:
		$Name.editable = false
		$LoginButton.disabled = true
		StrandService.connect("connected", self, "_on_StrandService_connected")
		StrandService.connect("connect_failed", self, "_on_StrandService_connect_failed")
		StrandService.NewPlayer($Name.text)

func _on_StrandService_connected(id):
	$NameLabel.text = "Connected! Player ID = " + str(id)
	$AnimationPlayer.play("FadeOut")

func _on_StrandService_connect_failed(reason):
	$NameLabel.text = "Failed to connect! Reason: " + reason

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/forest/ForestScene.tscn")
