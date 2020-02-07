extends Node2D

# warning-ignore:unused_argument
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
