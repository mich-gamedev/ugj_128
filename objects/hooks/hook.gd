class_name Hook extends Area2D

@export var draw_debug: bool = false

@export_group("Separation", "sep_")
@export var sep_distance: float = 64.
@export_exp_easing var sep_ease: float = 1
@export var sep_force: float = 1.
@export var sep_area: Area2D

@export_group("Hook Attraction", "hook_")
@export var hook_force: float = 1.0
@export var hook_self_strength: float = 1.0

@export_group("Coherence", "coh_")
@export var coh_distance: float = 128.
@export_exp_easing var coh_ease: float = 1
@export var coh_force: float = 1.
@export var coh_area: Area2D

@export_group("Alignment", "align_")
@export var align_distance: float = 160.
@export_exp_easing var align_ease: float = 1
@export var align_force: float = 1.
@export var align_area: Area2D

@export_group("Edge resistance", "edge_")
@export var edge_distance: float = 32
@export_exp_easing var edge_ease: float = 1
@export var edge_force: float = 10.

@export_group("Velocity")
@export_range(0, 1000, 0.01, "or_greater", "prefix:px/s") var min_speed: float = 32.
@export_range(0, 1000, 0.01, "or_greater", "prefix:px/s") var regular_speed: float = 128.
@export_range(-180, 180, 0.01, "radians_as_degrees") var turn_speed: float = PI/8
@export var turn_force: float = 1.
@export_range(0, 1, 0.0000000000000000000000000000001) var acceleration_weight: float = 0.0000000001


var hooks: Array[Hook]

var velocity: Vector2

signal hooked(to: Hook)
signal hook_received(from: Hook)
signal hook_added(other: Hook)

var forces: Array[Callable] = [get_separation, get_coherence, get_alignment, get_hook, get_turn, get_edge_resist]

func _physics_process(delta: float) -> void:
	var force_vecs: Array[Vector2]
	for i in forces:
		force_vecs.append(i.call() as Vector2)
	var _tmp := Vector2.ZERO
	for i in force_vecs:
		_tmp += i
	var length : float = force_vecs.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / forces.size()
	var total_force := _tmp.normalized() * length
	velocity = velocity.lerp(
		total_force.normalized() * remap(total_force.length(), 0, 1, min_speed, regular_speed),
		1 - acceleration_weight ** delta
	)
	global_position += velocity * delta
	queue_redraw()

func get_separation() -> Vector2:
	var result: Array[Vector2]

	for i in sep_area.get_overlapping_areas():
		var vec := -global_position.direction_to(i.global_position)
		vec *= ease((sep_distance - global_position.distance_to(i.global_position)) / sep_distance, sep_ease)
		result.append(vec)
	if result.is_empty(): return Vector2.ZERO
	var avg_distance = result.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / result.size()
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * sep_force * avg_distance

func get_coherence() -> Vector2:
	var result: Array[Vector2]
	for i in coh_area.get_overlapping_areas():
		var vec := global_position.direction_to(i.global_position)
		vec *= ease((coh_distance - global_position.distance_to(i.global_position)) / coh_distance, coh_ease)
		result.append(vec)
	if result.is_empty(): return Vector2.ZERO
	var avg_distance = result.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / result.size()
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * coh_force * avg_distance

func get_alignment() -> Vector2:
	var result: Array[Vector2]
	for i in align_area.get_overlapping_areas():
		if i is Hook:
			var vec := i.velocity.normalized() as Vector2
			vec *= ease((align_distance - global_position.distance_to(i.global_position)) / align_distance, align_ease)
			result.append(vec)
	if result.is_empty(): return Vector2.ZERO
	var avg_distance = result.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / result.size()
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * align_force * avg_distance

func get_hook() -> Vector2:
	var result: Array[Vector2]
	for i: Hook in hooks:
		result.append(global_position.direction_to(i.global_position) * i.hook_self_strength)
	if result.is_empty(): return Vector2.ZERO
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * hook_force * hooks.reduce(func(accum: float, i: Hook): return accum + (global_position.dot(i.global_position) * i.hook_self_strength), 0)

func get_turn() -> Vector2:
	return velocity.normalized().rotated(turn_speed * get_physics_process_delta_time()) * turn_force

func get_edge_resist() -> Vector2:
	var edge := get_tree().get_first_node_in_group(&"edge_curve") as Path2D
	var closest_point := edge.curve.get_closest_point(edge.to_local(global_position))
	var distance = edge.to_local(global_position).distance_to(closest_point)
	return -(edge.to_local(global_position).direction_to(closest_point)) * ease((edge_distance - distance) / edge_distance, edge_ease) * edge_force

func can_hook() -> bool:
	return _can_hook()

func _can_hook() -> bool:
	return true

static func add_hook(from: Hook, to: Hook) -> bool:
	if !(from.can_hook() and to.can_hook()): return false
	from.hooks.append(to)
	to.hooks.append(from)
	from.hooked.emit(to)
	from.hook_added.emit(to)
	to.hook_received.emit(from)
	to.hook_added.emit(from)
	return true

func _draw() -> void:
	if !draw_debug: return
	draw_circle(Vector2.ZERO, sep_distance, Color.RED, false)
	draw_circle(Vector2.ZERO, coh_distance, Color.AQUAMARINE, false)
	draw_circle(Vector2.ZERO, align_distance, Color.SPRING_GREEN, false)
	draw_circle(Vector2.ZERO, edge_distance, Color.MAROON, false)
	for i in forces:
		var result = i.call()
		draw_line(Vector2.ZERO, result * 24, Color.AQUA)
		draw_string(
			ThemeDB.fallback_font,
			result * 24,
			i.get_method() + ": " + str(result),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 4
		)
