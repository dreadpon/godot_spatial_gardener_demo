extends PanelContainer


func _ready():
	ShowcaseSettings.connect("updated_setting", on_updated_setting)
	on_updated_setting("show_hud", "interface", ShowcaseSettings.get_setting_val("show_hud"))


func on_updated_setting(setting_id:String, section:String, val):
	if section == "interface" && setting_id == "show_hud":
		visible = val




func _process(delta):
	$FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
