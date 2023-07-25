@tool
extends Control


@onready var speed_name := $CenterContainer/HBoxContainer/Names/SpeedName
@onready var speed_val := $CenterContainer/HBoxContainer/Vals/SpeedVal
@onready var status_name := $CenterContainer/HBoxContainer/Names/StatusName
@onready var status_val := $CenterContainer/HBoxContainer/Vals/StatusVal
@onready var departure_name := $CenterContainer/HBoxContainer/Names/DepartureName
@onready var departure_val := $CenterContainer/HBoxContainer/Vals/DepartureVal


func set_speed_val(val:String):
	speed_val.text = val


func set_status_val(val:String):
	status_val.text = val


func set_departure_val(val:String):
	departure_val.text = val


func set_departure_visibility(state:bool):
	departure_name.visible = state
	departure_val.visible = state
