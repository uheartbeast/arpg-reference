extends Position2D

onready var start_position = global_position
onready var timer = $Timer

func _on_Timer_timeout():
	global_position = start_position + Vector2(rand_range(-1, 1), rand_range(-1, 1)) * 32
	timer.wait_time = rand_range(1, 3)

# Starting Position
# Wander Point (relative to the starting position)
# Wander and Idle
# Interval (to switch between wander and idle)
# Chase state has priority over the wander and idle states
