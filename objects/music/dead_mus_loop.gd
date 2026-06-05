extends AudioStreamPlayer

var base_vol: float;

func _ready() -> void:
	base_vol = volume_linear
	volume_linear = 0;
	GameStats.signals.state_changed.connect(dead)

func dead(state: int) -> void:
	if GameStats.state == GameStats.GAME_OVER:
		var tween: Tween = get_tree().create_tween()
		tween.tween_interval(1.5)
		tween.tween_property(self, "volume_linear", base_vol, 3.0)
		tween.play()
