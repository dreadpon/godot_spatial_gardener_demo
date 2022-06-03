extends DirectionalLight




func _ready():
	ShowcaseSettings.connect("updated_setting", self, "on_updated_setting")
	set_preset(ShowcaseSettings.get_setting_val("rendering_quality"))


func on_updated_setting(setting_id:String, section:String, val):
	if section == "graphics" && setting_id == "rendering_quality":
		set_preset(val)


func set_preset(preset_float:float):
	var preset := int(round(preset_float))
	match preset:
		
		0:
			directional_shadow_mode = DirectionalLight.SHADOW_ORTHOGONAL
			directional_shadow_max_distance = 150.0
			directional_shadow_normal_bias = 4.0
			shadow_bias = 4.0
		
		1:
			directional_shadow_mode = DirectionalLight.SHADOW_PARALLEL_2_SPLITS
			directional_shadow_max_distance = 300.0
			directional_shadow_normal_bias = 2.0
			shadow_bias = 0.5
		
		2:
			directional_shadow_mode = DirectionalLight.SHADOW_PARALLEL_4_SPLITS
			directional_shadow_max_distance = 300.0
			directional_shadow_normal_bias = 1.5
			shadow_bias = 0.5
