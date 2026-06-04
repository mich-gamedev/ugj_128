@tool
class_name GroupedButtonAnim extends Node

@export var button: Button:
	set(v):
		if !is_node_ready(): await ready
		if !is_instance_valid(v): v = get_parent()
		if is_instance_valid(button):
			button.mouse_entered.disconnect(_mouse_entered)
			button.mouse_exited.disconnect(_mouse_exited)
		button = v
		v.mouse_entered.connect(_mouse_entered)
		v.mouse_exited.connect(_mouse_exited)

@export var base_stretch_ratio: float = 1
@export var hover_stretch_ratio: float = 1.5

var twn: Tween

func _mouse_entered() -> void:
	if Engine.is_editor_hint(): return
	if twn: twn.kill()
	twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	twn.tween_property(button, ^"size_flags_stretch_ratio", 1.5, 0.35)

func _mouse_exited() -> void:
	if Engine.is_editor_hint(): return
	if twn: twn.kill()
	twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	twn.tween_property(button, ^"size_flags_stretch_ratio", 1, 0.35)
