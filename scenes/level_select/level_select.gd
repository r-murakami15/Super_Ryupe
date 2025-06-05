extends Control

@onready var level_buttons = [
	$CanvasLayer/Button01,
	$CanvasLayer/Button02,
	$CanvasLayer/Button03,
	$CanvasLayer/Button04,
	$CanvasLayer/Button05,
	$CanvasLayer/Button06,
]
@onready var back_button = $CanvasLayer/BackButton

# 現在のフォーカスインデックス
var current_focus_index = 0

func _ready() -> void:
	get_tree().paused = false  # メニュー画面が表示される時、ゲームの一時停止を解除する
	
	# 各ボタンにシグナルを接続
	for i in range(level_buttons.size()):
		var button: Button = level_buttons[i]
		button.pressed.connect(_on_level_button_pressed.bind(i + 1))
		
		# マウスフィルターを設定（オプション）
		button.mouse_filter = Control.MOUSE_FILTER_PASS
	
	back_button.pressed.connect(_on_back_button_pressed.bind())

# レベルボタンを押されたら、レベルシーンへ遷移
func _on_level_button_pressed(level_number: int):
	var lev_num_str = "%02d" % level_number  # ２桁になるように0埋めする
	#print("Level " + lev_num_str + " selected")
	#print("res://scenes/level_{0}/level_01.tscn".format([lev_num_str]))
	
	# レベルシーンへ遷移
	get_tree().change_scene_to_file("res://scenes/stages/level_{0}/level_{0}.tscn".format([lev_num_str]))

func _on_back_button_pressed():
	GameManager.load_main_scene()
