class_name World extends Node2D

@onready var bounds: ReferenceRect = %BoundsRect
@onready var spawn_timer: Timer = %SpawnAttemptTimer

const GAME_OVER = preload("uid://ejgi2xvv1tnq")

static var max_hooks := 15
static var world: World

const FISH_HIGH_SCORE = preload("uid://d8i3yxn84yi4")

func _ready() -> void:
	world = self
	for i in Hook.get_hook_spawns():
		i.make_defaults()
	if SaveData.data.high_score:
		var inst := FISH_HIGH_SCORE.instantiate() as Hook
		inst.position = Vector2(242, 129)
		add_child.call_deferred(inst)
	GameStats.start_new()
	GameStats.state = GameStats.MAIN_MENU
	GameStats.signals.state_changed.connect(_state_changed)
	Performance.add_custom_monitor("FishCount", func() -> int: return Engine.get_main_loop().get_nodes_in_group(&"hook").size())

func _state_changed(new: int) -> void:
	if new == GameStats.IN_GAME:
		spawn_timer.start()
		GameStats.start_new()
	if new == GameStats.GAME_OVER:
		var inst := GAME_OVER.instantiate() as CanvasLayer
		add_child(inst)

func _spawn_timeout() -> void:
	spawn_timer.start(randf_range(0, 0.35))
	if get_tree().get_nodes_in_group(&"hook").size() >= max_hooks: return
	var hook := Hook.random()
	if (!GameStats.pack.discoveries.has(hook.resource_path)) and (!SaveData.data.high_score.discoveries.has(hook.resource_path)):
		GameStats.pack.discoveries.append(hook.resource_path)
	var inst := hook.get_hook()

	var rect := bounds.get_global_rect()
	inst.global_position = Vector2(
		randi_range(rect.position.x, rect.end.x),
		randi_range(rect.position.y, rect.end.y)
	)
	inst.reset_physics_interpolation()
