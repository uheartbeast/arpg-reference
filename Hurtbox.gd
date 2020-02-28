extends Area2D

export(bool) var show_hit = true

const HitEffect = preload("HitEffect.tscn")

func _on_Hurtbox_area_entered(area):
	if show_hit:
		var effect = HitEffect.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position - Vector2(0, 8)
