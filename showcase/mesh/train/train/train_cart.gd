tool
extends KinematicBody


export var animation_name:String = ""
export var animation_multiplier:float = 1.0
export var animation_direction:float = 1.0
export var animation_speed_world_basis:float = 10.0
export var debug_velocity:Vector3 = Vector3.ZERO
var velocity:Vector3 = Vector3.ZERO
var prev_position = null


onready var anim_player:AnimationPlayer = $AnimationPlayer




func _physics_process(delta):
	if prev_position != null:
		velocity = global_transform.origin - prev_position 
		velocity /= delta
		velocity += debug_velocity
	prev_position = global_transform.origin
	
	anim_player.playback_speed = get_playback_speed(animation_speed_world_basis)


func get_playback_speed(basis:float):
	return velocity.length() / basis * animation_direction * animation_multiplier


func _ready():
	anim_player.get_animation(animation_name).set_loop(true)
	anim_player.play(animation_name)
