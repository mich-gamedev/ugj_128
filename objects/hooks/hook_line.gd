extends Line2D

var from: Hook
var to: Hook
var reach_from: float
var reach_to: float

@onready var outline: Line2D = %Outline

func _ready() -> void:
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).tween_property(self, ^"reach_to", 1, 0.5)
	from.hook_detatched_from.connect(hook_detatched.bind(to))
	to.hook_detatched_from.connect(hook_detatched.bind(from))

func _process(delta: float) -> void:
	if is_instance_valid(from) and is_instance_valid(to):
		clear_points()
		gradient.colors[0] = from.main_color
		gradient.colors[1] = to.main_color
		add_point(to_local(from.global_position).lerp(to_local(to.global_position), reach_from))
		add_point(to_local(from.global_position).lerp(to_local(to.global_position), reach_to))
		outline.points = points

func hook_detatched(detatched: Hook, origin: Hook) -> void:
	if detatched in [from, to]:
		if origin == from:
			create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).tween_property(self, ^"reach_to", 0, 0.5)
		else:
			create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).tween_property(self, ^"reach_from", 1, 0.5)
		if !is_inside_tree(): return # sometimes when i exit the game the line below causes a crash instead which is annoying. so this stops that
		await get_tree().create_timer(.5).timeout
		queue_free()
