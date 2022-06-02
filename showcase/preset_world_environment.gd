extends WorldEnvironment




func _ready():
	ShowcaseSettings.connect("updated_setting", self, "on_updated_setting")
	on_updated_setting("dof_blur", "graphics", ShowcaseSettings.get_setting_val("dof_blur"))
	on_updated_setting("dof_blur_quality", "graphics", ShowcaseSettings.get_setting_val("dof_blur_quality"))


func on_updated_setting(setting_id:String, section:String, val):
	if section == "graphics" && setting_id == "dof_blur":
		environment.dof_blur_far_enabled = val
	elif section == "graphics" && setting_id == "dof_blur_quality":
		environment.dof_blur_far_quality = int(val)
