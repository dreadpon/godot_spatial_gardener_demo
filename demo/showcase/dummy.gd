extends Node


func _ready():
	if !ShowcaseSettings.scene_to_restart.is_empty():
		get_tree().change_scene_to_file(ShowcaseSettings.scene_to_restart)
		ShowcaseSettings.scene_to_restart = ""
