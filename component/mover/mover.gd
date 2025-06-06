extends Node2D

@export var is_move: bool = true  # 移動をさせるかを管理するフラグ
@export var distance: Vector2 = Vector2(200, 0)  # 移動距離
@export var time: float = 2.0  # 移動にかかる時間
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT  # イージングタイプ
@export var trans_type: Tween.TransitionType = Tween.TRANS_SINE  # トランジションタイプ

var start_position: Vector2  # 開始位置
var end_position: Vector2    # 終了位置
var tween: Tween             # Tweenオブジェクト
var moving_forward: bool = true  # 前進中かどうかのフラグ
var parent: Node2D           # 親ノード

func _ready() -> void:
	parent = get_parent()
	if not parent:
		return
		
	# 開始位置を記録（親ノードの位置）
	start_position = parent.position
	# 終了位置を計算
	end_position = start_position + distance
	
	# 移動フラグがtrueの場合、移動を開始
	if is_move:
		start_moving()

func start_moving():
	"""移動を開始する"""
	if not is_move or not parent:
		return
	
	# 既存のTweenを停止
	if tween:
		tween.kill()
	
	# 親ノードでTweenを作成
	tween = parent.create_tween()
	tween.set_loops()  # 無限ループに設定
	
	# 往復移動のアニメーションを設定
	create_loop_animation()

func create_loop_animation():
	"""往復移動のアニメーションを作成"""
	if not parent or not tween:
		return
	
	# 親ノードを開始位置から終了位置へ移動
	var tween_to_end = tween.tween_property(parent, "position", end_position, time)
	tween_to_end.set_ease(ease_type)
	tween_to_end.set_trans(trans_type)
	
	# 親ノードを終了位置から開始位置へ移動
	var tween_to_start = tween.tween_property(parent, "position", start_position, time)
	tween_to_start.set_ease(ease_type)
	tween_to_start.set_trans(trans_type)

# 移動を停止する
func stop_moving():
	if tween:
		tween.kill()

# 可視性が変わった時の処理（オプション）
func _on_visibility_changed():
	if visible and is_move:
		start_moving()
	elif not visible:
		stop_moving()
