tool
extends KinematicBody


const MovementMode = preload("movement_mode.gd")


#export(Array, Resource) var movement_modes:Array = [] setget set_movement_modes
export(Resource) var walk_mode = null setget set_walk_mode
export(Resource) var run_mode = null setget set_run_mode
export(Resource) var fall_mode = null setget set_fall_mode
# TODO add fly mode
#export(Resource) var fly_mode = null setget set_fly_mode

export var gravity:float = 9.8
export var weight:float = 5.0
export var jump_acceleration:float = 20.0
export var mouse_sensitivity:float = 0.2
export var controller_sensitivity:float = 400.0
export var allowed_slope:float = 75.0
export var bobbing_speed_walk:float = 8.0
export var bobbing_speed_run:float = 12.0
export var fall_sfx_trigger_distance:float = 2.0

var current_movement_mode:MovementMode = null
var velocity:Vector3 = Vector3()
var input_direction:Vector3 = Vector3()
var movement_snapping:Vector3 = Vector3()
var floor_velocity:Vector3 = Vector3()
var last_floor_state:bool = false
var camera_bob_duration:float = 0.0
var h_oscillator:Oscillator = Oscillator.new(0.2, 1.0)
var v_oscillator:Oscillator = Oscillator.new(0.075, 2.0)
var r_z_oscillator:Oscillator = Oscillator.new(0.25, 1.0)
var distance_fallen:float = 0.0


onready var camera_axis = $CameraAxis
onready var camera = $CameraAxis/Camera




func set_walk_mode(val):
	walk_mode = val
	if !(walk_mode is MovementMode):
		walk_mode = MovementMode.new(MovementMode.MovementType.WALK)


func set_run_mode(val):
	run_mode = val
	if !(run_mode is MovementMode):
		run_mode = MovementMode.new(MovementMode.MovementType.RUN)


func set_fall_mode(val):
	fall_mode = val
	if !(fall_mode is MovementMode):
		fall_mode = MovementMode.new(MovementMode.MovementType.FALL)




func _ready():
	if Engine.editor_hint: return
	# A bit of a hack to prevent input while scene is loading
	# Since engine accumulates all inputs during that time and them fleshes them all at once
	get_tree().get_root().set_disable_input(true)
	get_tree().get_root().call_deferred("set_disable_input", false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)


func _unhandled_input(event):
	if Engine.editor_hint: return
	
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_sensitivity_actual = mouse_sensitivity#* ShowcaseSettings.get_setting_val("mouse_sensitivity")
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity_actual))
		camera_axis.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity_actual))
		camera_axis.rotation.x = clamp(camera_axis.rotation.x, deg2rad(-89), deg2rad(89))


func _process(delta):
	if Engine.editor_hint: return
	rotate_controller_camera(delta)


func _physics_process(delta):
	if Engine.editor_hint: return
	update_input_direction()
	update_movement_mode()
	update_velocity(delta)
	move_controller()
	apply_camera_bob(delta)
	input_direction = Vector3()


func rotate_controller_camera(delta):
	var controller_sensitivity_actual = controller_sensitivity# * ShowcaseSettings.get_setting_val("controller_sensitivity")
	if Input.is_action_pressed("camera_left"):
		rotate_y(deg2rad(controller_sensitivity_actual * Input.get_action_strength("camera_left") * delta))
	if Input.is_action_pressed("camera_right"):
		rotate_y(deg2rad(controller_sensitivity_actual * Input.get_action_strength("camera_right") * delta * -1.0))
	if Input.is_action_pressed("camera_up"):
		camera_axis.rotate_x(deg2rad(controller_sensitivity_actual * Input.get_action_strength("camera_up") * delta))
	if Input.is_action_pressed("camera_down"):
		camera_axis.rotate_x(deg2rad(controller_sensitivity_actual * Input.get_action_strength("camera_down") * delta * -1.0))
	
	camera_axis.rotation.x = clamp(camera_axis.rotation.x, deg2rad(-89), deg2rad(89))


func update_input_direction():
	if !is_processing_input(): return
	
	if current_movement_mode && current_movement_mode.movement_type == MovementMode.MovementType.FLY:
		input_direction = Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_up") - Input.get_action_strength("move_down"),
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).normalized()
	else:
		input_direction = Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			0.0,
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).normalized()


func update_movement_mode():
	var floor_state = is_on_floor()
	if floor_state:
		floor_velocity = get_floor_velocity()
		if Input.is_action_pressed("run"):
			current_movement_mode = run_mode
		else:
			current_movement_mode = walk_mode
	else:
		current_movement_mode = fall_mode
	
	if !floor_state && last_floor_state:
		velocity += floor_velocity
		floor_velocity = Vector3()
	elif floor_state && !last_floor_state:
		velocity -= floor_velocity
		if distance_fallen >= fall_sfx_trigger_distance:
			play_sfx("land")
		distance_fallen = 0.0
	
	last_floor_state = is_on_floor()


func update_velocity(delta):
	if !current_movement_mode: return
	
	match current_movement_mode.movement_type:
		
		MovementMode.MovementType.WALK, MovementMode.MovementType.RUN:
			movement_snapping = -get_floor_normal()
			velocity.y = 0.0
		
		MovementMode.MovementType.FALL:
			movement_snapping = Vector3.DOWN
			velocity += Vector3.DOWN * gravity * weight * delta
		
#		MovementMode.MovementType.FLY:
#			pass
	
	if is_processing_input():
		if Input.is_action_just_pressed("jump") && is_on_floor():
			movement_snapping = Vector3.ZERO
			velocity += Vector3.UP * jump_acceleration
			play_sfx("jump")
	
	if input_direction.length_squared() > 0:
		var input_direction_rotated = input_direction.rotated(global_transform.basis.y, deg2rad(rotation_degrees.y))
		var input_velocity = input_direction_rotated * current_movement_mode.acceleration * delta
		
		if velocity.length() < current_movement_mode.max_speed || (velocity + input_velocity).length() < velocity.length():
			velocity += input_velocity
	else:
		velocity = velocity.normalized() * clamp(velocity.length() - current_movement_mode.decceleration * delta, 0.0, INF)
	
	if velocity.length() > current_movement_mode.max_speed:
		velocity = velocity.normalized() * clamp(velocity.length() - current_movement_mode.dampening * delta, 0.0, INF)


func move_controller():
	var delta_move = global_transform.origin
	move_and_slide_with_snap(velocity, movement_snapping, Vector3.UP, false, 4, deg2rad(allowed_slope))
	delta_move = global_transform.origin - delta_move
	
	if current_movement_mode.movement_type == MovementMode.MovementType.FALL:
		distance_fallen += delta_move.length()


func apply_camera_bob(delta):
	if !is_on_floor(): return
	var speed = Vector3(velocity.x, 0.0, velocity.z).length()
	if speed <= 0.0001: return
	
	var speed_based = speed
	if current_movement_mode == run_mode:
		speed_based /= bobbing_speed_run
	else:
		speed_based /= bobbing_speed_walk
	
	camera.transform.origin.x = h_oscillator.get_oscillation(delta, speed_based)
	camera.transform.origin.y = v_oscillator.get_oscillation(delta, speed_based)
	camera.rotation_degrees.y = r_z_oscillator.get_oscillation(delta, speed_based)
	
	if h_oscillator.reached_extremis:
		play_ground_sfx()


func play_ground_sfx():
	var ray_start = $Feet.global_transform.origin
	var ray_end = ray_start - Vector3(0, 1, 0)
	var ray_collision_mask = pow(2, 29) + pow(2, 30) + pow(2, 31)
	var result:Dictionary = get_world().direct_space_state.intersect_ray(ray_start, ray_end, [self], ray_collision_mask)
	if !result.empty():
		var sound_name = ""
		if result.collider.collision_layer & int(pow(2, 29)):
			sound_name = "step_rock"
		elif result.collider.collision_layer & int(pow(2, 30)):
			sound_name = "step_wood"
		elif result.collider.collision_layer & int(pow(2, 31)):
			sound_name = "step_dirt"
		play_sfx(sound_name)


func play_sfx(sfx_name:String):
	var audio_player = $ActionAudio
	audio_player.stream = load("res://showcase/audio/%s.ogg" % [sfx_name])
	audio_player.pitch_scale = rand_range(0.8, 1.5)
	audio_player.play(0.0)




class Oscillator extends Reference:
	var duration:float = 0.0
	var amplitude:float = 0.0
	var frequency:float = 1.0
	var reached_extremis:bool = false
	
	func _init(_amplitude:float = 0.0, _frequency:float = 1.0):
		amplitude = _amplitude
		frequency = _frequency
	
	
	func get_oscillation(delta:float, speed:float):
		var last_duration = duration
		duration += delta * speed
		
		if reached_extremis:
			reached_extremis = false
		if floor(last_duration / (1.0 / frequency * 0.5)) < floor(duration / (1.0 / frequency * 0.5)):
			reached_extremis = true
		
		return sin(duration * 2 * PI * frequency) * amplitude
