extends KinematicBody2D

const ACCELERATION = 400
const MAX_SPEED = 50

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = WANDER
#var wander_vector = Vector2.ZERO

onready var start_position = global_position

onready var sprite = $Sprite
onready var softCollision = $SoftCollision
onready var playerDetectionZone = $PlayerDetectionZone
onready var wanderPoint = $Node/WanderPoint

func _physics_process(delta):
	# Friction
	velocity = velocity.linear_interpolate(Vector2.ZERO, 0.1)
	knockback = knockback.linear_interpolate(Vector2.ZERO, 0.2)
	
	match state:
		IDLE:
			# Look for the player
			if playerDetectionZone.can_see_player():
				state = CHASE
		
		WANDER:
			# Look for the player
			if playerDetectionZone.can_see_player():
				state = CHASE
			sprite.flip_h = wanderPoint.position.x < 0
			velocity += (wanderPoint.global_position - global_position).normalized() * ACCELERATION * delta
			velocity = velocity.clamped(MAX_SPEED)
		
		CHASE:
			var player = playerDetectionZone.get_player()
			if player != null:
				var acceleration = (player.global_position - global_position).normalized() * ACCELERATION * delta
				sprite.flip_h = acceleration.x < 0
				velocity += acceleration
				velocity = velocity.clamped(MAX_SPEED)
			else:
				state = WANDER
	
	# Push
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	# Move
	velocity = move_and_slide(velocity + knockback)

func _on_Hurtbox_area_entered(area):
	# Knockback
	var knockback_vector = area.get_parent().get_parent().roll_vector # TODO: Clean this
	knockback += knockback_vector * 500
