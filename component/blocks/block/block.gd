extends Area2D

var players_on_block: Array[CharacterBody2D] = []  # ブロックに乗っているプレイヤーのリスト
var previous_position: Vector2  # 前フレームの位置（移動量計算用）

func _ready() -> void:
	previous_position = position  # 前フレーム位置も初期化

# プレイヤーの同期移動処理 (この関数は1秒間に必ず60回実行される)
func _physics_process(_delta: float):
	# ブロックの移動量を計算
	var movement_delta = position - previous_position
	
	# ブロックに乗っているプレイヤーを移動
	for player in players_on_block:
		if is_instance_valid(player):
			player.position += movement_delta
	
	# 現在の位置を記録
	previous_position = position

func _on_body_entered(body: Node2D) -> void:
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

func _on_body_exited(body: Node2D) -> void:
	print("何かがエリアから出ました: ", body.name)
	
	if body is Player:
		print("プレイヤーがブロックから離れました")
		# プレイヤーをリストから削除
		if body in players_on_block:
			players_on_block.erase(body)
