extends AudioStreamPlayer

@export var bpm: float = 132.0
@export var loop_beats: float = 128.0

func _ready() -> void:
	finished.connect(loop_midway)

func loop_midway():
	play(60/bpm * loop_beats)
