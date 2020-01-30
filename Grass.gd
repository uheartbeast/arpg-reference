extends Node2D

func _exit_tree():
	var GrassEffect = load("res://GrassEffect.tscn")
	var grassEffect = GrassEffect.instance()
	get_tree().current_scene.add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_Hurtbox_area_entered(area):
	queue_free()
