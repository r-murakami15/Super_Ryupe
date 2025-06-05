extends Node2D

@export var is_move: bool = false  # 移動をさせるかを管理するフラグ
@export var distance: Vector2 = Vector2.ZERO  # 移動距離
@export var time: float = 3.0  # 移動にかかる時間
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT  # イージングタイプ
@export var trans_type: Tween.TransitionType = Tween.TRANS_SINE  # トランジションタイプ

var start_position: Vector2  # 開始位置
var end_position: Vector2    # 終了位置
var tween: Tween             # Tweenオブジェクト
var moving_forward: bool = true  # 前進中かどうかのフラグ
var players_on_block: Array[CharacterBody2D] = []  # ブロックに乗っているプレイヤーのリスト
var previous_position: Vector2  # 前フレームの位置（移動量計算用）

func _ready():
	# 開始位置を記録
	start_position = position
	previous_position = position  # 前フレーム位置も初期化
	# 終了位置を計算
	end_position = start_position + distance
	
	# Tweenを作成
	tween = create_tween()
	tween.set_loops()  # 無限ループに設定
	
	# 移動フラグがtrueの場合、移動を開始
	if is_move:
		start_moving()

func _physics_process(delta):
	"""プレイヤーの同期移動処理"""
	# ブロックの移動量を計算
	var movement_delta = position - previous_position
	
	# ブロックに乗っているプレイヤーを移動
	for player in players_on_block:
		if is_instance_valid(player):
			player.position += movement_delta
	
	# 現在の位置を記録
	previous_position = position

func start_moving():
	"""移動を開始する"""
	if not is_move:
		return
	
	# 現在位置を記録
	previous_position = position
	
	# Tweenを停止してリセット
	tween.kill()
	tween = create_tween()
	tween.set_loops()
	
	# 往復移動のアニメーションを設定
	create_loop_animation()

func create_loop_animation():
	"""往復移動のアニメーションを作成"""
	# 現在位置から終了位置へ移動（終了時に減速）
	var tween_to_end = tween.tween_property(self, "position", end_position, time)
	tween_to_end.set_ease(ease_type)  # インスペクターで設定可能
	tween_to_end.set_trans(trans_type)  # インスペクターで設定可能
	
	# 終了位置から開始位置へ移動（終了時に減速）
	var tween_to_start = tween.tween_property(self, "position", start_position, time)
	tween_to_start.set_ease(ease_type)  # インスペクターで設定可能
	tween_to_start.set_trans(trans_type)  # インスペクターで設定可能

func stop_moving():
	"""移動を停止する"""
	if tween:
		tween.kill()

func _on_visibility_changed():
	"""可視性が変わった時の処理（オプション）"""
	if visible and is_move:
		start_moving()
	elif not visible:
		stop_moving()

# エディタでパラメータが変更された時の処理
func _set(property: StringName, value):
	match property:
		"is_move":
			is_move = value
			if is_inside_tree():
				if is_move:
					start_moving()
				else:
					stop_moving()
		"distance":
			distance = value
			if is_inside_tree():
				end_position = start_position + distance
				if is_move:
					start_moving()
		"time":
			time = value
			if is_inside_tree() and is_move:
				start_moving()
	return false


func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("")
	#print("===========================================")
	#print("何かがエリアに入りました: ", body.name, " (Type: ", body.get_class(), ")")
	if body is CharacterBody2D:
		#print("CharacterBody2Dが検出されました")
		if body is Player:
			#print("プレイヤーがブロックに乗りました。")
			# プレイヤーをリストに追加
			if body not in players_on_block:
				players_on_block.append(body)
		else:
			#print("CharacterBody2Dですが、Playerクラスではありません")
			pass
	else:
		#print("CharacterBody2D以外のオブジェクトです")
		pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	print("何かがエリアから出ました: ", body.name)
	
	if body is Player:
		print("プレイヤーがブロックから離れました")
		# プレイヤーをリストから削除
		if body in players_on_block:
			players_on_block.erase(body)
