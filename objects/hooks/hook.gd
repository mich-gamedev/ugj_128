class_name Hook extends Area2D

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

@export_group("Velocity")
@export_range(0, 1000, 0.01,"or_greater", "prefix:p/s") var default_speed: float = 64.
@export_range(-180, 180, 0.01, "radians_as_degrees") var default_turn_speed: float = PI/8

var hooks: Array[Hook]

var velocity: Vector2

func _physics_process(delta: float) -> void:
	pass

func get_separation() -> Vector2:
	var result: Array[Vector2]
	for i in sep_area.get_overlapping_areas():
		var vec := -global_position.direction_to(i.global_position)
		vec *= ease(global_position.distance_to(i.global_position) / sep_distance, sep_ease)
		result.append(vec)
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized()) * sep_force

func get_coherence() -> Vector2:
	var result: Array[Vector2]
	for i in coh_area.get_overlapping_areas():
		var vec := global_position.direction_to(i.global_position)
		vec *= ease(global_position.distance_to(i.global_position) / coh_distance, coh_ease)
		result.append(vec)
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized()) * coh_force

func get_alignment() -> Vector2:
	var result: Array[Vector2]
	for i in align_area.get_overlapping_areas():
		if i is Hook:
			var vec := i.velocity.normalized() as Vector2
			vec *= ease(global_position.distance_to(i.global_position) / align_distance, align_ease)
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized()) * align_force

func get_hook() -> Vector2:
	var result: Array[Vector2]
	for i: Hook in hooks:
		result.append(global_position.direction_to(i.global_position) * i.hook_self_strength)
	return result.reduce(func(accum: Vector2, i: Vector2) -> Vector2: return (accum + i).normalized()) * hook_force * hooks.reduce(func(accum: float, i: Hook): return global_position.dot(i.global_position) * i.hook_self_strength)
