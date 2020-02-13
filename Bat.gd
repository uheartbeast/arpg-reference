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

var state = IDLE

onready var sprite = $Sprite
onready var softCollision = $SoftCollision
onready var playerDetectionZone = $PlayerDetectionZone

func _physics_process(delta):
	# Friction
	velocity = velocity.linear_interpolate(Vector2.ZERO, 0.1)
	knockback = knockback.linear_interpolate(Vector2.ZERO, 0.2)
	
	match state:
		IDLE:
			pass
		
		WANDER:
			pass
		
		CHASE:
			pass
	
	# Push
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	# Move
	velocity = move_and_slide(velocity + knockback)

func _on_Hurtbox_area_entered(area):
	# Knockback
	var knockback_vector = area.get_parent().get_parent().roll_vector # TODO: Clean this
	knockback += knockback_vector * 500
