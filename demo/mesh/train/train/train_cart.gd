@tool
extends CharacterBody3D


@export var animation_name:String = ""
@export var animation_multiplier:float = 1.0
@export var animation_direction:float = 1.0
@export var animation_speed_world_basis:float = 5.0
@export var debug_manual_velocity:Vector3 = Vector3.ZERO
@export var imported_model: Node3D = null
var manual_velocity:Vector3 = Vector3.ZERO
var prev_position = null


@onready var anim_player:AnimationPlayer = imported_model.get_node("AnimationPlayer")




func _physics_process(delta):
	if prev_position != null:
		manual_velocity = global_transform.origin - prev_position 
		manual_velocity /= delta
		manual_velocity += debug_manual_velocity
	prev_position = global_transform.origin
	
	anim_player.speed_scale = get_playback_speed(animation_speed_world_basis)


func get_playback_speed(base:float):
	return manual_velocity.length() / base * animation_direction * animation_multiplier


func _ready():
	anim_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
	anim_player.play(animation_name)
