extends Node

static var last_track: int = -1

func _ready() -> void:
	var trackList = range(get_child_count())
	if last_track != -1:
		trackList.remove_at(last_track)

	last_track = trackList.pick_random()
	get_child(last_track).play()

	GameStats.signals.state_changed.connect(dead)

func dead(state: int) -> void:
	if GameStats.state == GameStats.GAME_OVER:
		var tween: Tween = get_tree().create_tween()
		#tween.tween_property(get_child(last_track) as AudioStreamPlayer, "pitch_scale", 1.05, 0.25)
		tween.tween_property(get_child(last_track) as AudioStreamPlayer, "pitch_scale", 0.00001, 2.5)
		tween.tween_callback(get_child(last_track).stop)
		tween.play()
