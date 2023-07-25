extends WorldEnvironment




func _ready():
	ShowcaseSettings.connect("updated_setting", on_updated_setting)
	on_updated_setting("dof_blur", "graphics", ShowcaseSettings.get_setting_val("dof_blur"))
	on_updated_setting("dof_blur_quality", "graphics", ShowcaseSettings.get_setting_val("dof_blur_quality"))


func on_updated_setting(setting_id:String, section:String, val):
	if Engine.is_editor_hint(): return
	if section == "graphics" && setting_id == "dof_blur":
		camera_attributes.dof_blur_far_enabled = val
	elif section == "graphics" && setting_id == "dof_blur_quality":
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_shape", int(val))
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", int(val) + 1)
