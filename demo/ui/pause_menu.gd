extends Control


onready var button_resume := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer/VBoxContainer/ButtonResume
onready var button_restart := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer/VBoxContainer/ButtonRestart
onready var button_settings := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer/VBoxContainer/ButtonSettings
onready var button_quit := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer/ButtonQuit

onready var check_button_show_hud := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/CheckButtonShowHUD
onready var check_button_sound := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/CheckButtonSound
onready var slider_sound_volume := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/SliderSoundVolume
onready var check_button_fullscreen := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/CheckButtonFullscreen
onready var slider_rendering_quality := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/SliderRenderingQuality
onready var check_button_dof_blur := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/CheckButtonDOFBlur
onready var slider_dof_blur_quality := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/SliderDOFBlurQuality
onready var check_button_vsync := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/CheckButtonVSync
onready var slider_mouse_sensitivity := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/SliderMouseSensitivity
onready var slider_controller_sensitivity := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/HBoxContainer/GridContainer/SliderControllerSensitivity

onready var window_tab_container := $CenterContainer/VBoxContainer/WindowTabContainer

onready var button_needs_reboot := $CenterContainer/VBoxContainer/WindowTabContainer/VBoxContainer3/ButtonReturn/Control/ButtonNeedsReboot


var needs_reboot:bool = false setget set_needs_reboot



func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	check_button_show_hud.pressed = ShowcaseSettings.get_setting_val("show_hud")
	check_button_sound.pressed = ShowcaseSettings.get_setting_val("sound")
	slider_sound_volume.value = ShowcaseSettings.get_setting_val("sound_volume")
	check_button_fullscreen.pressed = ShowcaseSettings.get_setting_val("fullscreen")
	slider_rendering_quality.value = ShowcaseSettings.get_setting_val("rendering_quality")
	check_button_dof_blur.pressed = ShowcaseSettings.get_setting_val("dof_blur")
	slider_dof_blur_quality.value = ShowcaseSettings.get_setting_val("dof_blur_quality")
	check_button_vsync.pressed = ShowcaseSettings.get_setting_val("vsync")
	slider_mouse_sensitivity.value = ShowcaseSettings.get_setting_val("mouse_sensitivity")
	slider_controller_sensitivity.value = ShowcaseSettings.get_setting_val("controller_sensitivity")
	show_tab(0)


func _unhandled_input(event):
	if event.is_action_released("pause"):
#	if event is InputEventKey && event.scancode == KEY_ESCAPE && !event.pressed:
		toggle_pause_menu()


func toggle_pause_menu():
	if !visible:
		show_tab(0)
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false


func show_tab(index:int):
	window_tab_container.current_tab = index
	
	if Input.get_connected_joypads().empty(): return
	match index:
		0:
			button_resume.grab_focus()
		1:
			check_button_sound.grab_focus()


func resume():
	toggle_pause_menu()


func quit():
	get_tree().quit()


func set_setting(value, setting:String):
	if setting == "rendering_quality" && value != ShowcaseSettings.get_setting_val("rendering_quality"):
		set_needs_reboot(true)
	else:
		set_needs_reboot(false)
	ShowcaseSettings.set_setting(setting, value, true)


func set_needs_reboot(val):
	needs_reboot = val
	button_needs_reboot.visible = needs_reboot


func restart():
	resume()
	ShowcaseSettings.restart(get_tree().current_scene.filename)
