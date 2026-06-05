extends CanvasLayer

@onready var cursor: Node2D = $Cursor

enum {
	NORMAL,
	HAND_OPEN,
	HAND_CLOSED
}

func _process(_delta: float) -> void:
	cursor.global_position = cursor.get_global_mouse_position()

func make_visible(child: int) -> void:
	for i in cursor.get_children():
		if i is Node2D:
			i.visible = i.get_index() == child
