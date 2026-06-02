extends Node2D

@export var hook: Hook

func _ready() -> void:
	hook.hooked.connect(_hooked)
	hook.deleting.connect(_deleting)
	scale = Vector2.ZERO
	twn_drag = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	twn_drag.tween_property(self, ^"scale", Vector2.ONE, 0.75 * randf_range(2, 5))
	if hook is DraggableHook:
		hook.drag_started.connect(_drag_started)
		hook.drag_ended.connect(_drag_ended)

var twn_drag: Tween

func _drag_started() -> void:
	if twn_drag: twn_drag.kill()
	twn_drag = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	twn_drag.tween_property(self, ^"scale", Vector2.ONE * 1.5, .5)

func _drag_ended() -> void:
	if twn_drag: twn_drag.kill()
	twn_drag = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	twn_drag.tween_property(self, ^"scale", Vector2.ONE, 1.5)

const HOOK_LINE = preload("uid://bdh0i7iq0tv0h")

func _hooked(to: Hook) -> void:
	var inst := HOOK_LINE.instantiate() as Line2D
	inst.from = hook
	inst.to = to
	get_tree().current_scene.add_child(inst)

func _deleting() -> void:
	if twn_drag: twn_drag.kill()
	twn_drag = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	twn_drag.tween_property(self, ^"scale", Vector2.ZERO, .5)
	twn_drag.tween_property(self, ^'global_position', get_tree().get_first_node_in_group(&"raft").global_position, 0.5)
