extends Node


const Globals = preload("../../addons/dreadpon.spatial_gardener/utility/globals.gd")


var dir_root_user:String = "user://"
var dir_root_save:String  = "save_files"

var file_settings:String  = "settings"
var ext_settings:String  = ".cfg"

var scene_to_restart:String = ""


var default_settings = {
	"show_hud": {
		"section": "interface", 
		"val": true
	},
	"sound": {
		"section": "sound", 
		"val": true
	},
	"sound_volume": {
		"section": "sound", 
		"val": 1.0
	},
	"rendering_quality": {
		"section": "graphics", 
		"val": 1
	},
	"fullscreen": {
		"section": "graphics", 
		"val": false
	},
	"dof_blur": {
		"section": "graphics", 
		"val": false
	},
	"dof_blur_quality": {
		"section": "graphics", 
		"val": 1
	},
	"vsync": {
		"section": "graphics", 
		"val": false
	},
	"mouse_sensitivity": {
		"section": "controls", 
		"val": 0.5
	},
	"controller_sensitivity": {
		"section": "controls", 
		"val": 0.5
	},
}
var settings = default_settings.duplicate(true)


signal updated_setting(setting_id, section, val)



func _ready():
	create_save_directories()
	load_all_settings()


func create_save_directories():
	var path_settings = get_path_settings()
	var full_path = get_config_file_path()
	
	if !DirAccess.dir_exists_absolute(path_settings):
		DirAccess.make_dir_recursive_absolute(path_settings)


func load_all_settings():
	var config = ConfigFile.new()
	var full_path = get_config_file_path()
	
	var error = config.load(full_path)
#	if error != OK:
#		print("Config file loading failed: %s, error %s!" % [full_path, Globals.get_err_message(error)])
	
	for setting_id in settings:
		var section = settings[setting_id]["section"]
		var default_val = default_settings[setting_id]["val"]
		set_setting(setting_id, config.get_value(section, setting_id, default_val), false)


func get_path_settings():
	return dir_root_user + dir_root_save + "/"


func get_config_file_path():
	return get_path_settings() + file_settings + ext_settings


func set_setting(setting_id:String, val, write_to_file:bool):
	if !settings.has(setting_id):
		settings[setting_id] = {"section": "NONE", "val": null}
	
	settings[setting_id]["val"] = val
	var section = settings[setting_id]["section"]
	
	match setting_id:
		"sound":
			AudioServer.set_bus_mute(0, !val) 
		"sound_volume":
			AudioServer.set_bus_volume_db(0, linear_to_db(val))
		"fullscreen":
			get_window().set_deferred("mode", Window.MODE_EXCLUSIVE_FULLSCREEN if (val) else Window.MODE_WINDOWED)
		"vsync":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (val) else DisplayServer.VSYNC_DISABLED)
		"rendering_quality":
			set_rendering_quality(int(round(val)))
	
	if write_to_file:
		save_setting_val(section, setting_id, val)
	emit_signal("updated_setting", setting_id, section, val)


func get_setting_val(setting_id:String):
	if !settings.has(setting_id): return null
	return settings[setting_id]["val"]


func save_setting_val(setting_section:String, setting_id:String, setting_val):
	var config = ConfigFile.new()
	var full_path = get_config_file_path()
	
	var error = config.load(full_path)
	if error == OK:
		config.set_value(setting_section, setting_id, setting_val)
#		print("Set setting: [%s], in section: [%s], with val: [%s]" % [setting_id, setting_section, str(setting_val)])
		save_config(config, full_path)
#	else:
#		print("Config file loading failed: %s, error %s!" % [full_path, Globals.get_err_message(error)])


func reset_settings():
	settings = default_settings.duplicate(true)
	for setting_id in settings:
		var default_val = default_settings[setting_id]["val"]
		set_setting(setting_id, default_val, true)


func save_config(config:ConfigFile, full_path:String):
	var error = config.save(full_path)
#	if error == OK:
#		print("Config file saved: %s" % [full_path])
#	else:
#		print("Config file saving failed: %s, error %s!" % [full_path, Globals.get_err_message(error)])


func set_rendering_quality(stage:int):
	var config = ConfigFile.new()
	var full_path = get_config_file_path()
	config.load(full_path)
	
	match stage:
		
		0:
			config.set_value("rendering", "quality/filters/use_nearest_mipmap_filter", true)
			config.set_value("rendering", "quality/filters/msaa", 1)
			config.set_value("rendering", "quality/filters/use_fxaa", false)
			config.set_value("rendering", "quality/filters/use_debanding", false)
			config.set_value("rendering", "quality/directional_shadow/size", 2048)
			config.set_value("rendering", "quality/directional_shadow/size.mobile", 512)
			config.set_value("rendering", "rendering/lights_and_shadows/shadow_atlas/size", 2048)
			config.set_value("rendering", "rendering/lights_and_shadows/shadow_atlas/size.mobile", 512)
			config.set_value("rendering", "rendering/quality/shadows/filter_mode", 1)
			config.set_value("rendering", "rendering/quality/shadows/filter_mode.mobile", 0)
		
		1:
			config.set_value("rendering", "quality/filters/use_nearest_mipmap_filter", false)
			config.set_value("rendering", "quality/filters/msaa", 2)
			config.set_value("rendering", "quality/filters/use_fxaa", true)
			config.set_value("rendering", "quality/filters/use_debanding", false)
			config.set_value("rendering", "quality/directional_shadow/size", 4096)
			config.set_value("rendering", "quality/directional_shadow/size.mobile", 1024)
			config.set_value("rendering", "rendering/lights_and_shadows/shadow_atlas/size", 4096)
			config.set_value("rendering", "rendering/lights_and_shadows/shadow_atlas/size.mobile", 1024)
			config.set_value("rendering", "rendering/quality/shadows/filter_mode", 2)
			config.set_value("rendering", "rendering/quality/shadows/filter_mode.mobile", 1)
		
		2:
			config.set_value("rendering", "quality/filters/use_nearest_mipmap_filter", false)
			config.set_value("rendering", "quality/filters/msaa", 3)
			config.set_value("rendering", "quality/filters/use_fxaa", true)
			config.set_value("rendering", "quality/filters/use_debanding", true)
			config.set_value("rendering", "quality/directional_shadow/size.mobile", 2048)
			config.set_value("rendering", "quality/directional_shadow/size", 8192)
			config.set_value("rendering", "rendering/lights_and_shadows/shadow_atlas/size", 8192)
			config.set_value("rendering", "rendering/lights_and_shadows/shadow_atlas/size.mobile", 2048)
			config.set_value("rendering", "rendering/quality/shadows/filter_mode", 2)
			config.set_value("rendering", "rendering/quality/shadows/filter_mode.mobile", 1)
	
	config.save(full_path)


func restart(scene_path:String):
	# This is a workaround
	# Because Godot doesn't consider current scene 'freed' if we try to reload out current scene right here
	# This leads to all resource getting 'shared' between current scene an it's reloaded version
	# In short, if we express some level state using resources (say, timers for world events)
	# This state will be cached and NOT reset
	# Which is not what I expect from reloading a level :/
	
	# So we introduce an intermediate scene that allows Godot to mark all previous resources as free and clean them up
	scene_to_restart = scene_path
	get_tree().change_scene_to_file("res://demo/showcase/dummy.tscn")
