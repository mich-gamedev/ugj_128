class_name Raft extends Area2D

static var raft: Raft

const EARN_POPUP = preload("uid://c851w1lsmyj2y")

var twn_points: Tween
var twn_time: Tween
static var points: int:
	set(v):
		var diff := v - points
		points = v
		if v >= needed_points:
			points = 0
			needed_points *= randf_range(.9, 2.5)
			wait_time *= randf_range(1, 1.15)
			World.max_hooks *= randf_range(1.1, 1.5)
			World.max_hooks = min(World.max_hooks, 64)
			time_left = wait_time
			GameStats.pack.quotas += 1
		raft.points_label.text = "[font otv='wght=800']%d[color=#6e738d]/%d" % [points, needed_points]
		if raft.twn_points: raft.twn_points.kill()
		raft.twn_points = raft.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
		raft.twn_points.tween_property(raft.points_label, ^"scale", Vector2.ONE, .5).from(Vector2(1.25, 1 / 1.25))
		raft.twn_points.tween_property(raft.points_bar, ^"value", points, 0.15).set_trans(Tween.TRANS_CUBIC)
		raft.twn_points.tween_property(raft.points_bar, ^"max_value", needed_points, 0.15).set_trans(Tween.TRANS_CUBIC)
		if diff > 0:
			var inst := EARN_POPUP.instantiate() as Node2D
			(inst.get_node(^"Label") as RichTextLabel).text = "[font otv='wght=900']%+d" % diff
			if diff >= 10:
				(inst.get_node(^"Label") as RichTextLabel).add_theme_color_override(&"default_color", Color("#a6da95"))
			raft.add_child(inst)
			inst.position = Vector2.from_angle(randf() * TAU) * sqrt(randf_range(0, 625)) # 625 == 25 ** 2
			inst.reset_physics_interpolation()
static var needed_points: int = 30
static var wait_time: float = 45:
	set(v):
		wait_time = v
		if raft.twn_time: raft.twn_time.kill()
		raft.twn_time = raft.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		raft.twn_time.tween_property(raft.time_label, ^"scale", Vector2.ONE, 1.5).from(Vector2.ONE * 2.5)
static var time_left: float = wait_time

@onready var time_label: RichTextLabel = %TimeLabel
@onready var points_label: RichTextLabel = %PointsLabel
@onready var points_bar: ProgressBar = %PointsBar
@onready var anim_ui: AnimationPlayer = %AnimUI

func reset() -> void:
	points = 0
	needed_points = 30
	wait_time = 45
	time_left = wait_time

func _ready() -> void:
	raft = self
	reset()
	GameStats.signals.state_changed.connect(func(new: int) -> void:
		if new == GameStats.IN_GAME: anim_ui.play(&"show")
	)

func _process(delta: float) -> void:
	if GameStats.state == GameStats.IN_GAME:
		time_left -= delta
		GameStats.pack.time_elapsed += delta
		time_label.text = "[font otv='wght=600']%02d:%02d left" % [Time.get_time_dict_from_unix_time(time_left).minute, Time.get_time_dict_from_unix_time(time_left).second]
		if time_left < 0:
			GameStats.state = GameStats.GAME_OVER

		if time_left <= 6:
			time_label.add_theme_color_override(&"default_color", Color("#a6da95") if fmod(time_left, .3) > .15 else Color("#ed8796"))
		elif time_left <= 11:
			time_label.add_theme_color_override(&"default_color", Color("#a6da95") if fmod(time_left, 1) > .5 else Color("#ed8796"))
		elif time_left <= 21:
			time_label.add_theme_color_override(&"default_color", Color("#a6da95") if fmod(time_left, 2) > 1 else Color("#ed8796"))
		else:
			time_label.add_theme_color_override(&"default_color", Color("#a6da95"))


func _on_area_entered(area: Area2D) -> void:
	if GameStats.state == GameStats.GAME_OVER: return
	if area is Hook:
		area.collected.emit()
		area.delete()

		if points + area.cost >= needed_points:
			%RoundClear.play()

		points += area.cost

		%PlopSFX.play();
		if area.cost >= 10:
			%GreenPts1SFX.play()
		if area.cost >= 20:
			%GreenPts2SFX.play()
		GameStats.pack.total_points += area.cost
