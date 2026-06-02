class_name Hook extends Area2D

@export var draw_debug: bool = false
@export var cost: int = 1

@export_group("Visuals")
@export var main_color: Color
@export var radius: float = 8

@export_group("Separation", "sep_")
@export var sep_distance: float = 64.
@export_exp_easing var sep_ease: float = 1
@export var sep_force: float = 1.
@export var sep_self_strength: float = 1.0
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
@export var edge_force: float = 10.:
	get:
		return edge_force if hooks.is_empty() else maxf(edge_force, 2)

@export_group("Raft resistance", "raft_")
@export var raft_distance: float = 48.
@export_exp_easing var raft_ease: float = 1
@export var raft_force: float = .5
@export var raft_area: Area2D

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
signal hook_removed(other: Hook)
signal hook_detatched_from(from: Hook)
signal deleting

var forces: Array[Callable] = [get_separation, get_coherence, get_alignment, get_hook, get_turn, get_edge_resist, get_raft]

func _ready() -> void:
	set_collision_layer_value(2, true)

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
	if !bounds_rect.has_point(global_position):
		global_position.x = wrapf(global_position.x, bounds_rect.position.x, bounds_rect.end.x)
		global_position.y = wrapf(global_position.y, bounds_rect.position.y, bounds_rect.end.y)
		reset_physics_interpolation()
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
		if i is Hook: vec *= i.sep_self_strength
		result.append(vec)
	if result.is_empty(): return Vector2.ZERO
	var avg_distance = result.reduce(func(accum: float, i: Vector2) -> float: return accum + i.length(), 0) / result.size()
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized(), Vector2.ZERO) * sep_force * avg_distance

func get_raft() -> Vector2:
	if raft_force == 0: return Vector2()
	for i in raft_area.get_overlapping_areas():
		if i.is_in_group(&"raft"):
			var vec := -global_position.direction_to(i.global_position)
			vec *= ease((raft_distance - global_position.distance_to(i.global_position)) / raft_distance, raft_ease)
			return vec
	return Vector2()

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
	return true

static func remove_hook(from: Hook, to: Hook) -> void:
	if !from.hooks.has(to):
		push_error("Hooks already attached!")
		return
	from._connected_cache = []
	to._connected_cache = []
	from.hooks.erase(to)
	to.hooks.erase(from)
	from.hook_removed.emit(to)
	to.hook_removed.emit(from)
	from.hook_detatched_from.emit(to)

static var _spawns_cache: Array[HookSpawnrate]
static func get_hook_spawns() -> Array[HookSpawnrate]:
	const DIR := "res://objects/hooks/spawnrates/"
	if !_spawns_cache:
		var directories := DirAccess.get_directories_at(DIR)
		for i in directories:
			var path := DIR.path_join(i).path_join("hook.tres")
			if i.begins_with("_") or !ResourceLoader.exists(path): continue
			_spawns_cache.append(load(path))
	return _spawns_cache

static func random() -> HookSpawnrate:
	var weights : Dictionary[HookSpawnrate, float]
	for i in get_hook_spawns():
		weights[i] = i.spawnrate.sample(min(Raft.points, Raft.needed_points / 2) / 100.)
	var rng := RandomNumberGenerator.new()
	rng.seed = randi()
	return weights.keys()[rng.rand_weighted(weights.values())]

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


func _exit_tree() -> void:
	for i in hooks:
		Hook.remove_hook(i, self)

func delete() -> void:
	for i in hooks:
		Hook.remove_hook(self, i)
	deleting.emit()
	await get_tree().create_timer(0.5).timeout
	queue_free()
