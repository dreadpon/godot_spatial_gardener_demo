@tool
extends PathFollow3D




#func _physics_process(delta):
##	if rotation_mode == ROTATION_ORIENTED:
#		var path = get_parent()
#		var curve:Curve3D = path.curve
#		var point_coord := curve.get_closest_point(global_transform.origin) #progress / curve.get_baked_length() * curve.get_baked_points().size()
#		var point_start := int(floor(point_coord))
#		var point_end := int(ceil(point_coord))
#		var lerp_weight = point_coord - floor(point_coord)
#
#		if path.fixed_baked_fwd_vectors.size() <= max(point_start, point_end) || path.fixed_baked_up_vectors.size() <= max(point_start, point_end): return
#
#		var up_vec = lerp(path.fixed_baked_up_vectors[point_start], path.fixed_baked_up_vectors[point_end], lerp_weight)
#		var fwd_vec = lerp(path.fixed_baked_fwd_vectors[point_start], path.fixed_baked_fwd_vectors[point_end], lerp_weight)
#
#		transform.basis.y = up_vec.normalized()
#		transform.basis.z = transform.basis.x.cross(transform.basis.y)
#		transform.basis.x = transform.basis.y.cross(transform.basis.z)
#		scale = Vector3(1, 1, 1)
#
