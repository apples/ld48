extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$ErrorLabel.hide()
	StrandService.connect("connected", self, "_on_StrandService_connected")
	StrandService.connect("connect_failed", self, "_on_StrandService_connect_failed")
	StrandService.login()

func _on_StrandService_connected(id):
	$AnimationPlayer.play("FadeOut")

func _on_StrandService_connect_failed(reason):
	$ConnectingLabel.hide()
	$ErrorLabel.show()
	$ErrorLabel.text = reason

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/forest/ForestScene.tscn")
