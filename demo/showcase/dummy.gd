extends Node


func _ready():
	if !ShowcaseSettings.scene_to_restart.empty():
		get_tree().change_scene(ShowcaseSettings.scene_to_restart)
		ShowcaseSettings.scene_to_restart = ""
