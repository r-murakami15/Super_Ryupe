extends Area2D
class_name Fan

var players_on_fan: Array[Player] = []

func _physics_process(delta: float):
	# Playerクラスで定義されている重力と同等(980.0)
	var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
	# ファンの角度を取得
	var fan_angle_rad: float = transform.get_rotation() + PI / 2
	# 移動量を計算
	var fan_vector: float = -GRAVITY * 1.5 * delta
	var force: Vector2 = Vector2(fan_vector * cos(fan_angle_rad), fan_vector * sin(fan_angle_rad))
	#print("")
	#print('{0} : '.format([get_node(".").name]) , force)
	#print("ファンの角度(deg): ", rad_to_deg(fan_angle_rad))
	#print("ファンの角度(rad): ", fan_angle_rad)
	# ファンに載っているプレイヤーを上昇させる
	for player: Player in players_on_fan:
		if is_instance_valid(player):
			player.velocity += force
			

func _on_body_entered(body: Node2D) -> void:
	#print("")
	#print("===========================================")
	#print("あ、何かがエリアに入りました: ", body.name, " (Type: ", body.get_class(), ")")
	if body is CharacterBody2D:
		#print("CharacterBody2Dが検出されました")
		if body is Player:
			#print("プレイヤーがファンに乗りました")
			players_on_fan.append(body)
			body.send_player("ふわふわ～")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if body in players_on_fan:
			#print("プレイヤーがファンから降りました")
			players_on_fan.erase(body)
			await get_tree().create_timer(1).timeout
			body.send_player()
