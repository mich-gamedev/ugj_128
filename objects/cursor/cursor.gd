extends Node2D

enum {
	NORMAL,
	HAND_OPEN,
	HAND_CLOSED
}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()

func make_visible(child: int) -> void:
	for i in get_children():
		if i is Node2D:
			i.visible = i.get_index() == child
