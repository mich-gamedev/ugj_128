class_name World extends Node2D

@onready var bounds: ReferenceRect = %BoundsRect
@onready var spawn_timer: Timer = %SpawnAttemptTimer

static var max_hooks := 15

func _spawn_timeout() -> void:
	if get_tree().get_nodes_in_group(&"hook").size() >= max_hooks: return
	var inst := Hook.random().scene.instantiate() as Hook
	add_child(inst)
	var rect := bounds.get_global_rect()
	inst.global_position = Vector2(
		randi_range(rect.position.x, rect.end.x),
		randi_range(rect.position.y, rect.end.y)
	)
	inst.reset_physics_interpolation()
