extends KinematicBody2D

const EnemyDeathEffect = preload("res://EnemyDeathEffect.tscn")
const ACCELERATION = 300
const MAX_SPEED = 50

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = IDLE

onready var sprite = $Sprite
onready var softCollision = $SoftCollision
onready var playerDetectionZone = $PlayerDetectionZone
onready var stateTimer = $StateTimer
onready var wanderController = $WanderController
onready var stats = $Stats
onready var hitAnimationPlayer = $HitAnimationPlayer

func _physics_process(delta):
	
	knockback = knockback.linear_interpolate(Vector2.ZERO, 0.1)
	
	match state:
		IDLE:
			# Friction
			velocity = velocity.linear_interpolate(Vector2.ZERO, 0.1)
			
			seek_player()
			if stateTimer.time_left == 0:
				state = Utils.choose([IDLE, WANDER])
				stateTimer.start(rand_range(1, 3))
		
		WANDER:
			seek_player()
			if stateTimer.time_left == 0:
				state = Utils.choose([IDLE, WANDER])
				stateTimer.start(rand_range(1, 3))
			accelerate_to_point(wanderController.get_target_position(), ACCELERATION * delta)
			if (wanderController.get_target_position() - global_position).length() < 4:
				state = Utils.choose([IDLE, WANDER])
				stateTimer.start(rand_range(1, 3))
			
		CHASE:
			var player = playerDetectionZone.get_player()
			if player != null:
				accelerate_to_point(player.global_position, ACCELERATION * delta)
			else:
				state = IDLE
	
	check_soft_body_collision(delta)
	update_position()

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func check_soft_body_collision(delta):
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400

func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.clamped(MAX_SPEED)

func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	sprite.flip_h = acceleration_vector.x < 0
	accelerate(acceleration_vector)

func update_position():
	knockback = move_and_slide(knockback)
	velocity = move_and_slide(velocity)

func _on_Hurtbox_area_entered(area):
	# Knockback
	var knockback_vector = area.get_parent().get_parent().roll_vector # TODO: Clean this
	knockback = knockback_vector * 400
	stats.health -= 1
	hitAnimationPlayer.play("Hit")

func _on_Stats_no_health():
	queue_free()
	var effect = EnemyDeathEffect.instance()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position-Vector2(0, 8)
