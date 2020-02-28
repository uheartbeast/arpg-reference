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
var knockback = Vector2.ZERO
var input_vector = Vector2.ZERO
var roll_vector = Vector2.RIGHT
var invincible = false

onready var sprite = $Sprite
onready var swordHitboxAxis = $SwordHitboxAxis
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var softCollision = $SoftCollision
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	PlayerStats.connect("no_health", self, "queue_free")

func _process(delta):
	knockback = knockback.linear_interpolate(Vector2.ZERO, 0.2)
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	match state:
		MOVE:
			update_input_vector()
			if is_attempting_motion():
				update_animation_to("Run")
				flip_the_sprite()
				update_animation_blend_positions()
				apply_acceleration(delta)
				limit_speed_by_max_speed()
				update_roll_vector()
				rotate_sword_hitbox()
			else:
				update_animation_to("Idle")
				apply_friction()
			
			confirm_attack()
			confirm_roll()
			move()
		
		ROLL:
			set_roll_speed()
			update_animation_to("Roll")
			move()
		
		ATTACK:
			update_animation_to("Attack")
			apply_friction()
			move()


func change_state_to(new_state):
	state = new_state
	
func update_input_vector():
	input_vector = Vector2.ZERO
	input_vector.x =  Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()

func update_roll_vector():
	roll_vector = input_vector

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
	animationTree.set("parameters/Roll/blend_position", input_vector)

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

func set_roll_speed():
	velocity = roll_vector * MAX_SPEED * 1.5

func confirm_attack():
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func confirm_roll():
	if Input.is_action_just_pressed("roll"):
		change_state_to(ROLL)

func apply_friction():
	velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)

func move():
	velocity = move_and_slide(velocity + knockback)

func end_attack():
	change_state_to(MOVE)

func end_roll():
	change_state_to(MOVE)

func _on_Hurtbox_area_entered(area):
	if invincible != true:
		PlayerStats.health -= 1
		knockback = (global_position - area.global_position).normalized() * 200
		$HitAnimationPlayer.play("Blink")
		invincible = true
