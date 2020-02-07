extends KinematicBody2D

var velocity = Vector2.ZERO

onready var softCollision = $SoftCollision

func _physics_process(delta):
	velocity = velocity.linear_interpolate(Vector2.ZERO, 0.1)
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	velocity = move_and_slide(velocity)

func _on_Hurtbox_area_entered(area):
	var knockback_vector = area.get_parent().get_parent().roll_vector
	velocity += knockback_vector * 500
