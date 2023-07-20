@tool
extends "train_cart.gd"

@export var emit_smoke:bool = true: set = set_emit_smoke
@export var rail_damp_speed:float = 10.0

@onready var train_display = $SubViewport/TrainDisplay: set = set_train_display


func set_emit_smoke(val):
	emit_smoke = val
	if !is_inside_tree(): return
	$smoke.emitting = emit_smoke
	$audio.playing = true
	$audio2.playing = true


func _ready():
	super()
	set_emit_smoke(emit_smoke)


func _physics_process(delta):
	super(delta)
	var alpha = 1.0 - clamp(velocity.length() / rail_damp_speed, 0.0, 1.0)
	AudioServer.get_bus_effect(3, 0).volume_db = alpha * -38.0


func set_train_display(val):
	train_display = val
