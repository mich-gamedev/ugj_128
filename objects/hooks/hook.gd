class_name Hook extends Area2D

@export var draw_debug: bool = false

@export_group("Visuals")
@export var main_color: Color
@export var radius: float = 8

@export_group("Separation", "sep_")
@export var sep_distance: float = 64.
@export_exp_easing var sep_ease: float = 1
@export var sep_force: float = 1.
@export var sep_area: Area2D

@export_group("Hook Attraction", "hook_")
@export var hook_distance: float = 360.
@export_exp_easing var hook_ease: float = 1.
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
@export_range(0, 1, 0.00000000000001) var acceleration_weight: float = 0.0000000001


var hooks: Array[Hook]

var velocity: Vector2

signal hooked(to: Hook)
signal hook_received(from: Hook)
signal hook_added(other: Hook)

var forces: Array[Callable] = [get_separation, get_coherence, get_alignment, get_hook, get_turn, get_edge_resist]

func _physics_process(delta: float) -> void:
	var force_vecs: Array[Vector2]
	for i in forces:
		var result = i.call()
		if result is Vector2:
			force_vecs.append(result)
		elif result is Array[Vector2]:
			force_vecs.append_array(result)
	force_vecs = force_vecs.filter(func(i: Vector2) -> bool: return !i.is_zero_approx())
	var _tmp := Vector2.ZERO
	for i in force_vecs:
		_tmp += i
	var length : float = force_vecs.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / forces.size()
	var total_force := _tmp.normalized() * length
	velocity = velocity.lerp(
		total_force.normalized() * remap(total_force.length(), 0, 1, min_speed, regular_speed),
		1 - acceleration_weight ** delta
	)
	_validate_velocity()
	global_position += velocity * delta
	var bounds_rect := (get_tree().get_first_node_in_group(&"bounds_rect") as Control).get_global_rect()
	bounds_rect = bounds_rect.grow(radius)
	global_position.x = wrapf(global_position.x, bounds_rect.position.x, bounds_rect.end.x)
	global_position.y = wrapf(global_position.y, bounds_rect.position.y, bounds_rect.end.y)
	queue_redraw()
	if get_hook(): print(get_hook())

func _validate_velocity() -> void:
	pass

func get_separation() -> Vector2:
	if sep_force == 0: return Vector2()
	var result: Array[Vector2]

	for i in sep_area.get_overlapping_areas():
		var vec := -global_position.direction_to(i.global_position)
		vec *= ease((sep_distance - global_position.distance_to(i.global_position)) / sep_distance, sep_ease)
		result.append(vec)
	if result.is_empty(): return Vector2.ZERO
	var avg_distance = result.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / result.size()
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * sep_force * avg_distance

func get_coherence() -> Vector2:
	if coh_force == 0: return Vector2()
	var result: Array[Vector2]
	for i in coh_area.get_overlapping_areas():
		var vec := global_position.direction_to(i.global_position)
		vec *= ease((coh_distance - global_position.distance_to(i.global_position)) / coh_distance, coh_ease)
		result.append(vec)
	if result.is_empty(): return Vector2.ZERO
	var avg_distance = result.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / result.size()
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * coh_force * avg_distance

func get_alignment() -> Vector2:
	if align_force == 0: return Vector2()
	var result: Array[Vector2]
	for i in align_area.get_overlapping_areas():
		if i is Hook:
			var vec := i.velocity.normalized() as Vector2
			vec *= ease((align_distance - global_position.distance_to(i.global_position)) / align_distance, align_ease)
			result.append(vec)
	if result.is_empty(): return Vector2.ZERO
	var avg_distance = result.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / result.size()
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * align_force * avg_distance

func get_hook() -> Array[Vector2]:
	var result: Array[Vector2]
	for i: Hook in hooks:
		var vec := global_position.direction_to(i.global_position)
		vec *= ease(global_position.distance_to(i.global_position) / hook_distance, hook_ease)
		vec *= i.hook_self_strength
		vec *= hook_force
		result.append(vec)
	return result

func get_turn() -> Vector2:
	if turn_force == 0: return Vector2()
	return velocity.normalized().rotated(turn_speed * get_physics_process_delta_time()) * turn_force

func get_edge_resist() -> Vector2:
	if edge_force == 0: return Vector2()
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
	from._connected_cache = []
	to._connected_cache = []
	from.hooks.append(to)
	to.hooks.append(from)
	from.hooked.emit(to)
	from.hook_added.emit(to)
	to.hook_received.emit(from)
	to.hook_added.emit(from)
	from.edge_force = maxf(from.edge_force, 2)
	to.edge_force = maxf(to.edge_force, 2)
	return true

func _draw() -> void:
	if !draw_debug: return
	draw_circle(Vector2.ZERO, sep_distance, Color.RED, false)
	draw_circle(Vector2.ZERO, coh_distance, Color.AQUAMARINE, false)
	draw_circle(Vector2.ZERO, align_distance, Color.SPRING_GREEN, false)
	draw_circle(Vector2.ZERO, edge_distance, Color.MAROON, false)
	for i in forces:
		var result = i.call()
		if result is Vector2:
			draw_line(Vector2.ZERO, result * 24, Color.AQUA * Color(1, 1, 1, result.length()))

			draw_string(
				ThemeDB.fallback_font,
				result * 24,
				i.get_method() + ": " + str(result),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 2, Color(1,1,1, result.length())
			)
		elif result is Array[Vector2]:
			for j in result:
				draw_line(Vector2.ZERO, j * 24, Color.AQUA * Color(1, 1, 1, j.length()))
				draw_string(
					ThemeDB.fallback_font,
					j * 24,
					i.get_method() + ": " + str(j),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 2, Color(1,1,1, j.length())
				)


var _connected_cache: Array[Hook]

func get_total_connected_hooks() -> Array[Hook]:
	if _connected_cache: return _connected_cache
	return _fetch_total_hooks([])

func _fetch_total_hooks(found: Array[Hook]) -> Array[Hook]:
	for i in hooks:
		if !found.has(i):
			found.append(i)
			i._fetch_total_hooks(found)
	return found
