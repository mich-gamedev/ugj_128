extends Node2D

func _anim_finished(anim_name: StringName) -> void:
	queue_free()
