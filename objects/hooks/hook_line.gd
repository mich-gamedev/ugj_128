extends Line2D

var from: Hook
var to: Hook
var reach: float

func _ready() -> void:
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).tween_property(self, ^"reach", 1, 0.5)

func _process(delta: float) -> void:
	if is_instance_valid(from) and is_instance_valid(to):
		clear_points()
		add_point(to_local(from.global_position))
		add_point(to_local(from.global_position).lerp(to_local(to.global_position), reach))
