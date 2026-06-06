extends CanvasLayer

@onready var quotas: Label = %Quotas
@onready var points: Label = %Points
@onready var time: Label = %Time
@onready var discoveries: VBoxContainer = %DiscoveriesContainer
@onready var anim: AnimationPlayer = %Anim
@onready var high_score_label: RichTextLabel = %HighScoreLabel
@onready var sep_discoveries_label: Label = %SepDiscoveriesLabel

const DISCOVER_PANEL = preload("uid://dh3w4l4j4274e")

var twn_filter: Tween

func _ready() -> void:
	if SaveData.data.high_score and SaveData.data.high_score.total_points < GameStats.pack.total_points:
		high_score_label.show()
	quotas.text = str(GameStats.pack.quotas)
	points.text = str(GameStats.pack.total_points)
	time.text = "%2d:%02d" % [
		Time.get_time_dict_from_unix_time(int(GameStats.pack.time_elapsed)).minute,
		Time.get_time_dict_from_unix_time(int(GameStats.pack.time_elapsed)).second
	]
	sep_discoveries_label.text %= [
		((SaveData.data.high_score.discoveries if SaveData.data.high_score else []) + GameStats.pack.discoveries).size(),
		Hook.get_hook_spawns().size()
	]
	for i in GameStats.pack.discoveries:
		var inst := DISCOVER_PANEL.instantiate() as DiscoverPanel
		inst.hook = load(i)
		discoveries.add_child(inst)
	if SaveData.data.do_filter_effect:
		AudioServer.set_bus_effect_enabled(3, 0, true)
		var effect := AudioServer.get_bus_effect(3, 0) as AudioEffectFilter # filter on In-game SFX
		twn_filter = create_tween()
		twn_filter.tween_property(effect, ^"cutoff_hz", 3000, 0.5)

func _on_retry_pressed() -> void:
	if twn_filter: twn_filter.kill()
	var effect := AudioServer.get_bus_effect(3, 0) as AudioEffectFilter # filter on In-game SFX
	twn_filter = get_tree().create_tween()
	twn_filter.tween_property(effect, ^"cutoff_hz", 20500, 0.5)
	twn_filter.tween_callback(func() -> void: AudioServer.set_bus_effect_enabled(3, 0, false))
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	GameStats.start_new() # handles save data
	get_tree().quit()
