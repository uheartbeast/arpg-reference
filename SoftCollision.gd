extends Area2D

signal collision_detected(collision_normal)

func is_colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0

func get_push_vector():
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	for area in areas:
		push_vector = (global_position - area.global_position).normalized()
	return push_vector
