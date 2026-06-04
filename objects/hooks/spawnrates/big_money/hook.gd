extends DraggableHook

func _ready() -> void:
	drag_started.connect(_drag_started)

func _drag_started() -> void:
	await get_tree().create_timer(0.05).timeout
	end_drag()
