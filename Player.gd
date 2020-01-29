extends KinematicBody2D

enum {
	MOVE,
	ATTACK
}

export(int) var MAX_SPEED = 60
export(int) var ACCELERATION = 400
export(float) var FRICTION = 0.4

var velocity = Vector2.ZERO
var state = MOVE

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _physics_process(delta):
	match state:
		MOVE:
			var input_vector = Vector2.ZERO
			input_vector.x =  Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			input_vector = input_vector.normalized()
			
			if input_vector != Vector2.ZERO:
				animationState.travel("Run")
				if input_vector.x < 0:
					sprite.scale.x = -1
				else:
					sprite.scale.x = 1
					
				animationTree.set("parameters/Idle/blend_position", input_vector)
				animationTree.set("parameters/Run/blend_position", input_vector)
				animationTree.set("parameters/Attack/blend_position", input_vector)
				
				
				velocity += input_vector * ACCELERATION * delta
				velocity = velocity.clamped(MAX_SPEED)
			else:
				animationState.travel("Idle")
				velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)
			
			if Input.is_action_just_pressed("ui_accept"):
				state = ATTACK
				
			
			velocity = move_and_slide(velocity)
		
		ATTACK:
			animationState.travel("Attack")
			velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)
			velocity = move_and_slide(velocity)

func end_attack():
	state = MOVE
