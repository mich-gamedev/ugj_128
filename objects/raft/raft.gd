extends Area2D

var points: int

func _on_area_entered(area: Area2D) -> void:
	if area is Hook:
		area.delete()
		points += 1
