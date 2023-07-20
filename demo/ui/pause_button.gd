extends Button


@export var pause_menu_PTH: NodePath = ""
var pause_menu:Control = null




func _ready():
	if has_node(pause_menu_PTH):
		pause_menu = get_node(pause_menu_PTH)


func toggle_pause_menu():
	if pause_menu:
		pause_menu.toggle_pause_menu()
