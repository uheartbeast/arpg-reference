extends Position2D

onready var timer = $Timer

func _on_Timer_timeout():
	global_position = get_parent().get_parent().start_position + Vector2(rand_range(-1, 1), rand_range(-1, 1)) * 32
	timer.wait_time = rand_range(1, 3)
