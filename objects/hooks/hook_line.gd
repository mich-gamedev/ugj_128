extends Line2D

var from: Hook
var to: Hook
var reach_from: float
var reach_to: float

@onready var outline: Line2D = %Outline
@onready var ray: RayCast2D = $Ray
var twn: Tween

func _ready() -> void:
	twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	twn.tween_property(self, ^"reach_to", 1, 0.5)
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
	else: queue_free()

func _physics_process(delta: float) -> void:
	if is_instance_valid(from) and is_instance_valid(to):
		ray.global_position = from.global_position
		ray.target_position = ray.to_local(to.global_position)
		ray.force_raycast_update()
		if ray.is_colliding():
			Hook.remove_hook(from, to)

func hook_detatched(detatched: Hook, origin: Hook) -> void:
	if detatched in [from, to]:
		if origin == from:
			if twn: twn.kill()
			twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
			twn.tween_property(self, ^"reach_to", 0, 0.5)
			twn.tween_property(self, ^"reach_from", 0, 0.5)
		else:
			if twn: twn.kill()
			twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
			twn.tween_property(self, ^"reach_from", 1, 0.5)
			twn.tween_property(self, ^"reach_to", 1, 0.5)
		if !is_inside_tree(): return # sometimes when i exit the game the line below causes a crash instead which is annoying. so this stops that
		await get_tree().create_timer(.5).timeout
		queue_free()
