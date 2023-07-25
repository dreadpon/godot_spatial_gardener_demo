@tool
extends Path3D


const FunLib = preload("res://addons/dreadpon.spatial_gardener/utility/fun_lib.gd")
const TrainStop = preload("train/train_stop.gd")


#@export var redraw:bool = false : set = set_redraw
@export var spacings:Array = []
@export var stops:Array[Resource] = [] : set = set_stops
@export var direction:float = 1.0
@export var max_speed:float = 30.0
@export var max_acceleration:float = 10.0
@export var move_in_editor:bool = false
@export var fixed_baked_up_vectors:PackedVector3Array
@export var fixed_baked_fwd_vectors:PackedVector3Array
@export var speed:float = 0.0
@export var acceleration:float = 0.0




#func _ready():
#	fix_up_vectors()


#func set_redraw(val):
#	redraw = false
#	if val && self.is_inside_tree():
#		fix_up_vectors()


#func fix_up_vectors():
#	var baked_points = curve.get_baked_points()
#	var baked_tilts = curve.get_baked_tilts()
#	var baked_up_vectors = curve.get_baked_up_vectors()
#	fixed_baked_fwd_vectors = PackedVector3Array()
#	fixed_baked_up_vectors = PackedVector3Array()
#
#	for i in range(0, baked_points.size()):
#		var fwd_vec:Vector3
#		if i < baked_points.size() - 1:
#			fwd_vec = (baked_points[i + 1] - baked_points[i]).normalized()
#		else:
#			fwd_vec = (baked_points[i] - baked_points[i - 1]).normalized()
#
#		var world_up_vec:Vector3 = fwd_vec.cross(Vector3.UP.cross(fwd_vec))
#		var tilted_world_up_vec:Vector3 = world_up_vec.rotated(fwd_vec, baked_tilts[i]).normalized()
#
#		fixed_baked_fwd_vectors.append(fwd_vec)
#		fixed_baked_up_vectors.append(tilted_world_up_vec)


func _physics_process(delta):
	if Engine.is_editor_hint() && !move_in_editor: return
	move(delta)


func move(delta:float):
	cleanup_spacings()
	var path_follows := []
	var path_follow_spacing = spacings.duplicate()
	
	for child in get_children():
		if !(child is PathFollow3D): continue
		path_follows.append(child)
	if path_follows.is_empty(): return
	
	if direction < 0.0:
		path_follows.reverse()
		path_follow_spacing.reverse()
	
	speed = clamp(speed + acceleration * delta, 0.0, max_speed)
	var last_pos = path_follows[0].progress
	var movement := speed * delta * direction
	
	for i in range(0, path_follows.size()):
		var path_follow:PathFollow3D = path_follows[i]
		
		if i == 0:
			path_follow.progress = path_follow.progress + movement
		else:
			var spacing = path_follow_spacing[i - 1] + path_follow_spacing[i]
			spacing *= direction * -1.0
			path_follow.progress = path_follows[i - 1].progress + spacing
	
	process_stops(delta, last_pos, path_follows[0].progress)
	
	var baked_length = curve.get_baked_length()
	if direction >= 0.0 && path_follows[0].progress >= baked_length - path_follow_spacing[0]:
		direction = -1.0
		set_emit_smoke(path_follows)
		set_animation_direction(path_follows, direction)
	elif direction < 0.0 && path_follows[0].progress <= 0.0 + path_follow_spacing[0]:
		direction = 1.0
		set_emit_smoke(path_follows)
		set_animation_direction(path_follows, direction)
	
	update_loco_display(path_follows)


func cleanup_spacings():
	spacings.resize(get_children().size())
	for i in range(0, spacings.size()):
		if !(spacings[i] is float):
			spacings[i] = 0.0


func set_emit_smoke(path_follows):
	var first_cart:Node3D = path_follows[0].get_child(0)
	var last_cart:Node3D = path_follows[path_follows.size() - 1].get_child(0)
	if first_cart.has_method("set_emit_smoke"):
		first_cart.set_emit_smoke(false)
	if last_cart.has_method("set_emit_smoke"):
		last_cart.set_emit_smoke(true)


func update_loco_display(path_follows):
	var locos := [path_follows[0].get_child(0), path_follows[path_follows.size() - 1].get_child(0)]
	for loco in locos:
		if !loco.has_method("set_train_display"): continue
		
		var status := "FULL SPEED"
		var departure_delay := 0.0
		
		for stop in stops:
			match stop.stop_type:
				TrainStop.StopType.STOP:
					if stop.stop_applied && stop.stop_time_left > departure_delay:
						status = "STOPPED"
						departure_delay = stop.stop_time_left
				TrainStop.StopType.SLOWDOWN:
					if stop.stop_applied && status == "FULL SPEED":
						status = "SLOWDOWN"
		
		loco.train_display.set_speed_val("%.0f u/s" % [speed])
		loco.train_display.set_status_val(status)
		if status == "STOPPED":
			loco.train_display.set_departure_visibility(true)
			var time_string = FunLib.msec_to_time(ceil(departure_delay * 1000.0), false, FunLib.TimeTrimMode.KEEP_THREE)
			loco.train_display.set_departure_val(time_string)
		else:
			loco.train_display.set_departure_visibility(false)


func set_animation_direction(path_follows, anim_direction):
	for path_follow in path_follows:
		path_follow.get_child(0).animation_direction = anim_direction


func set_stops(val):
	stops = val
	for i in range(0, stops.size()):
		if !(stops[i] is TrainStop):
			stops[i] = TrainStop.new()


func process_stops(delta:float, last_pos:float, current_pos:float):
	for stop in stops:
		match stop.stop_type:
			
			TrainStop.StopType.STOP:
				if stop.stop_applied:
					stop.stop_time_left -= delta
					if stop.stop_time_left <= 0.0:
						stop.stop_time_left = 0.0
						stop.stop_applied = false
						acceleration = max_acceleration
				
				if is_between(stop.start_pos, last_pos, current_pos) && !stop.stop_applied:
					stop.stop_applied = true
					stop.stop_time_left = stop.stop_duration
					acceleration = max_acceleration * -1.0
			
			TrainStop.StopType.SLOWDOWN:
				if is_between(current_pos, stop.start_pos, stop.end_pos):
					stop.stop_applied = true
				elif stop.stop_applied:
					stop.stop_applied = false
					acceleration = max_acceleration
				
				if stop.stop_applied:
					if speed > stop.speed_limit:
						acceleration = -max_acceleration
					else:
						acceleration = max_acceleration


func is_between(source:float, end_1:float, end_2:float) -> bool:
	return (end_1 <= source && source <= end_2) || (end_2 <= source && source <= end_1)
