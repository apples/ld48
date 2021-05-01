extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$ConnectingPanel.hide()
	$ErrorPanel.hide()

func _on_StrandService_connected(id):
	$AnimationPlayer.play("FadeOut")

func _on_StrandService_connect_failed(reason):
	StrandService.player_id = null
	StrandService.player_name = null
	$Panel/ConnectingLabel.hide()
	$ErrorPanel.show()
	$ErrorPanel/ErrorLabel.text = reason

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/forest/ForestScene.tscn")

func _on_RetryButton_pressed():
	$ErrorPanel/RetryButton.disabled = true
	$ErrorPanel/OfflineButton.disabled = true
	get_tree().reload_current_scene()

func _on_OfflineButton_pressed():
	$IntroPanel/LoginButton.disabled = true
	$IntroPanel/OfflineButton.disabled = true
	$ErrorPanel/RetryButton.disabled = true
	$ErrorPanel/OfflineButton.disabled = true
	$AnimationPlayer.play("FadeOut")


func _on_LoginButton_pressed():
	StrandService.connect("connected", self, "_on_StrandService_connected")
	StrandService.connect("connect_failed", self, "_on_StrandService_connect_failed")
	StrandService.login()
	$ConnectingPanel.show()
	$IntroPanel.hide()
