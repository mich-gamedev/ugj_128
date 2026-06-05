extends Label

func _ready() -> void:
	visible = SaveData.data.show_fps

func _physics_process(delta: float) -> void:
	text = "%dfps" % Engine.get_frames_per_second()
