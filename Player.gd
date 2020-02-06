extends KinematicBody2D

enum {
	MOVE,
	ROLL,
	ATTACK
}

export(int) var MAX_SPEED = 60
export(int) var ACCELERATION = 400
export(float) var FRICTION = 0.4

var state = MOVE
var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO
var is_attack_finished = false

onready var sprite = $Sprite
onready var swordHitboxAxis = $SwordHitboxAxis
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _process(delta):
	match state:
		MOVE:
			update_input_vector()
			if is_attempting_motion():
				update_animation_to("Run")
				flip_the_sprite()
				update_animation_blend_positions()
				apply_acceleration(delta)
				limit_speed_by_max_speed()
				rotate_sword_hitbox()
			else:
				update_animation_to("Idle")
				apply_friction()
			
			confirm_attack()
			move()
		
		ATTACK:
			update_animation_to("Attack")
			apply_friction()
			move()

func change_state_to(new_state):
	state = new_state
func update_input_vector():
	input_vector = Vector2.ZERO
	input_vector.x =  Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
func is_attempting_motion():
	return (input_vector != Vector2.ZERO)
func update_animation_to(animation_string):
	animationState.travel(animation_string)
func flip_the_sprite():
	if input_vector.x < 0:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1
func update_animation_blend_positions():
	animationTree.set("parameters/Idle/blend_position", input_vector)
	animationTree.set("parameters/Run/blend_position", input_vector)
	animationTree.set("parameters/Attack/blend_position", input_vector)
func rotate_sword_hitbox():
	if input_vector.x > 0:
		swordHitboxAxis.rotation_degrees = 0
	elif input_vector.x < 0:
		swordHitboxAxis.rotation_degrees = 180
	else:
		if input_vector.y > 0:
			swordHitboxAxis.rotation_degrees = 90
		else:
			swordHitboxAxis.rotation_degrees = -90
func apply_acceleration(delta):
	velocity += input_vector * ACCELERATION * delta
func limit_speed_by_max_speed():
	velocity = velocity.clamped(MAX_SPEED)
func confirm_attack():
	if Input.is_action_just_pressed("ui_accept"):
		state = ATTACK
func apply_friction():
	velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)
func move():
	velocity = move_and_slide(velocity)
func end_attack():
	change_state_to(MOVE)
