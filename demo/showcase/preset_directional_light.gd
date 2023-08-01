extends DirectionalLight3D




func _ready():
	ShowcaseSettings.connect("updated_setting", Callable(self, "on_updated_setting"))
	set_preset(ShowcaseSettings.get_setting_val("rendering_quality"))


func on_updated_setting(setting_id:String, section:String, val):
	if section == "graphics" && setting_id == "rendering_quality":
		set_preset(val)


func set_preset(preset_float:float):
	if Engine.is_editor_hint(): return
	var preset := int(round(preset_float))
	match preset:
		
		0:
			directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
			directional_shadow_max_distance = 150.0
			shadow_normal_bias = 1.0
			shadow_bias = 0.05
		
		1:
			directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
			directional_shadow_max_distance = 300.0
			shadow_normal_bias = 1.0
			shadow_bias = 0.05
		
		2:
			directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
			directional_shadow_max_distance = 300.0
			shadow_normal_bias = 1.0
			shadow_bias = 0.05
