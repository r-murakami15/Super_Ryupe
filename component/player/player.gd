extends CharacterBody2D
class_name Player

# プレイヤーの状態
enum PLAYER_STATE {
	IDLE,
	RUN,
	JUMP,
	FALL,
	HIT,
}

# 重力の設定
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# ノードの参照
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_label: Label = $VBoxContainer/PlayerLabel

# 移動関連の設定
@export_group("move")
@export var can_move: bool = false
@export var move_speed: float = 150.0

# ジャンプ関連の設定
@export_group("jump")
var max_y_velocity: float = 400  # 最大Y速度
var jump_force: float = 335.0  # 初期ジャンプ力
var min_jump_force: float = 235.0  # 最小ジャンプ力
var max_jump_time: float = 0.45  # 最大ジャンプ持続時間（秒）

#var jump_force: float = 390.0  # 初期ジャンプ力
#var min_jump_force: float = 185.0  # 最小ジャンプ力
#var max_jump_time: float = 0.6  # 最大ジャンプ持続時間（秒）

# ジャンプ制御用の変数
var is_jumping: bool = false  # ジャンプ中かどうか
var jump_time: float = 0.0  # ジャンプボタンを押している時間

# プレイヤーの移動と状態管理
var direction: Vector2 = Vector2.ZERO
var state: PLAYER_STATE = PLAYER_STATE.IDLE  # 現在の状態
var player_name = "りゅーぺ"

func _ready() -> void:
	player_label.text = player_name

# 物理処理のメインループ
func _physics_process(delta: float) -> void:
	apply_gravity(delta)  # 重力の適用
	fallen_off()  # 一定距離落下したらヒット状態に
	get_input(delta)  # 入力の取得
	apply_movement(delta)  # 移動の適用
	move_and_slide()  # スライドしながら移動
	update_state()  # 状態の更新

# 重力を適用
func apply_gravity(delta: float):
	if !is_on_floor():  # 床に触れていない場合
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, max_y_velocity)

# 一定距離落下したらプレイヤーをヒット状態に
func fallen_off():
	if global_position.y > 100:
		SignalManager.on_player_hit.emit()
	
# プレイヤーの入力を取得
func get_input(delta: float):
	# 操作可能ではないときは終了
	if not can_move:
		return
	
	# 左右移動の入力を取得
	direction.x = Input.get_axis("ui_left", "ui_right")
	
	# ジャンプの入力処理
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# ジャンプ開始
		start_jump()
	
	# ジャンプボタンを押し続けている間の処理
	if Input.is_action_pressed("jump") and is_jumping and !is_on_floor() and jump_time < max_jump_time:
		# ジャンプボタンを押し続けている間
		jump_time += delta
		# 持続ジャンプ力を適用
		apply_variable_jump_force(delta)
	
	if Input.is_action_just_released("jump") or jump_time >= max_jump_time:
		# ジャンプボタンを離した時、または最大時間に達した時
		end_jump()

# ジャンプを開始
func start_jump():
	is_jumping = true
	jump_time = 0.0
	# 最小ジャンプ力を即座に適用
	velocity.y = -min_jump_force

# 可変ジャンプ力を適用
func apply_variable_jump_force(delta: float):
	if velocity.y < 0:  # 上昇中のみ適用
		# ジャンプ時間に応じて追加の上昇力を適用
		var additional_force = (jump_force - min_jump_force) * (jump_time / max_jump_time)
		#print("------------上昇中-----------")
		#print("jump_time: ", jump_time)
		#print("上昇力： ", additional_force)
		#print("velocity.y 変更前: ", velocity.y)
		velocity.y -= additional_force * delta * 10  # 調整用の係数
		#print("velocity.y 変更後: ", velocity.y)

# ジャンプを終了
func end_jump():
	is_jumping = false

# プレイヤーの移動処理
func apply_movement(_delta: float):
	# 地面に着地したらジャンプ状態をリセット
	if is_on_floor() and is_jumping and velocity.y > 0:
		is_jumping = false
		jump_time = 0.0
	
	# 横方向の移動
	if direction.x:
		# プレイヤーの向きを左右反転
		animated_sprite_2d.flip_h = direction.x < 0
		velocity.x = direction.x * move_speed  # 横方向の移動速度
	else:
		velocity.x = 0  # 横方向の速度をリセット

# プレイヤーの状態を更新
func update_state():
	if is_on_floor():  # プレイヤーが地面に触れている場合
		if velocity.x == 0:
			set_state(PLAYER_STATE.IDLE)  # 待機状態
		else:
			set_state(PLAYER_STATE.RUN)  # 走行状態
	else:
		if velocity.y > 0:
			set_state(PLAYER_STATE.FALL)  # 落下状態
		else:
			set_state(PLAYER_STATE.JUMP)  # ジャンプ状態

# プレイヤーの状態を設定
func set_state(new_state: PLAYER_STATE):
	if new_state == state:  # 状態が変更されていない場合
		return
	
	state = new_state  # 新しい状態に変更
	
	match state:  # 状態に応じたアニメーションの再生
		PLAYER_STATE.IDLE:
			animated_sprite_2d.play("idle")
		PLAYER_STATE.RUN:
			animated_sprite_2d.play("run")
		PLAYER_STATE.JUMP:
			animated_sprite_2d.play("jump")
		PLAYER_STATE.FALL:
			animated_sprite_2d.play("fall")

func send_player(message = null):
	if message == null:
		player_label.text = player_name
	else:
		player_label.text = message

# プレイヤーのヒットボックスが何かに当たった時
func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("trap"):
		if area is Spike:
			velocity = Vector2.ZERO
			SignalManager.on_player_hit.emit()
			send_player("痛いっ")

# プレイヤーのヒットボックスから消えた時
func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("trap"):
		await get_tree().create_timer(0.5).timeout
		send_player()
		 
