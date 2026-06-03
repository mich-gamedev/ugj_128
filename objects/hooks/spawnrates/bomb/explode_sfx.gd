class_name ExplodeSFX
extends AudioStreamPlayer2D

func play_in_current_pos():
	var newSFX: ExplodeSFX = duplicate()
	get_tree().current_scene.add_child(newSFX)
	newSFX.global_position = global_position
	newSFX.stream = stream;
	newSFX.play()

func _on_finished() -> void:
	queue_free()
