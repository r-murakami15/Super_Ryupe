extends Node

# プリロード
const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const LEVEL_SELECT_SCENE: PackedScene = preload("res://scenes/level_select/level_select.tscn")

# メインメニューシーンをロードする関数
func load_main_scene():
	get_tree().change_scene_to_packed(MAIN_SCENE)

# レベル選択シーンをロードする関数
func load_level_select_scene():
	get_tree().change_scene_to_packed(LEVEL_SELECT_SCENE)
