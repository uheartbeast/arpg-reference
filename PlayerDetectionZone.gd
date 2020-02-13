extends Area2D

var player = null setget ,get_player

onready var wallCheck = $WallCheck

func _physics_process(delta):
	if player != null:
		wallCheck.cast_to = player.global_position - global_position
	
	$Sprite.visible = can_see_player()

func can_see_player():
	return player != null and not wallCheck.is_colliding()

func get_player():
	return player

func _on_PlayerDetectionZone_body_entered(body):
	self.player = body

func _on_PlayerDetectionZone_body_exited(body):
	self.player = null
