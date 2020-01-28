extends KinematicBody2D

export(int) var MAX_SPEED = 60
export(int) var ACCELERATION = 400
export(float) var FRICTION = 0.4

var velocity = Vector2.ZERO

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var runAnimationTree = $RunAnimationTree
onready var idleAnimationTree = $IdleAnimationTree

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x =  Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		if input_vector.x == -1:
			sprite.scale.x = -1
		else:
			sprite.scale.x = 1
		idleAnimationTree.active = false
		runAnimationTree.active = true
		runAnimationTree.set("parameters/blend_position", input_vector)
		idleAnimationTree.set("parameters/blend_position", input_vector)
		input_vector = input_vector.normalized()
		velocity += input_vector * ACCELERATION * delta
		velocity = velocity.clamped(MAX_SPEED)
	else:
		idleAnimationTree.active = true
		runAnimationTree.active = false
		velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)
	
	velocity = move_and_slide(velocity)

func get_direction_facing(angle):
	if angle >= -PI/3 && angle <= PI/3:
		return "Side"
	elif angle < -PI/3 && angle > -PI +(PI/3):
		return "Up"
	elif angle > PI/3 && angle < PI - (PI/3):
		return "Down"
	else:
		return "Side"