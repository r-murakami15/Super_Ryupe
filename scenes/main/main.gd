extends Node2D

@onready var start_button = $CanvasLayer/StartButton

func _ready() -> void:
	get_tree().paused = false  # メニュー画面が表示される時、ゲームの一時停止を解除する
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_button_pressed.bind())

#func _process(_delta: float) -> void:
	## スタートボタンが押されたらLevelSelectシーンへ遷移
	#if start_button.button_pressed:
		#GameManager.load_level_select_scene()

func _on_start_button_pressed():
	GameManager.load_level_select_scene()
