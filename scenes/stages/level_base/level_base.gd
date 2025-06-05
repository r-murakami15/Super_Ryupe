extends Node2D

@onready var camera: Camera2D = $Camera

#var camera_position = 

func _ready() -> void:
	get_tree().paused = false  # ゲームを開始する際には一時停止を解除
