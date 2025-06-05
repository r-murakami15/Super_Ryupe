extends ParallaxBackground

@onready var sprite_2d: Sprite2D = $ParallaxLayer/Sprite2D

@export var bg_texture: CompressedTexture2D = preload("res://assets/img/Background/Gray.png")
@export var scroll_speed = 5

func _ready() -> void:
	# 背景画像のテクスチャを設定
	sprite_2d.texture = bg_texture

func _process(delta: float) -> void:
	# 背景のスクロール処理
	sprite_2d.region_rect.position += delta * Vector2(scroll_speed, scroll_speed)
	
	# 一定距離を超えると位置をリセット
	if sprite_2d.region_rect.position >= Vector2(64, 64):
		sprite_2d.region_rect.position = Vector2.ZERO
