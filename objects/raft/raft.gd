extends Area2D

var points: int

@export var turn_noise: FastNoiseLite
@export var speed_noise: FastNoiseLite

var velocity := Vector2.RIGHT * 6

func _ready() -> void:
	turn_noise.seed = randi()
	speed_noise.seed = randi()

func _physics_process(delta: float) -> void:
	velocity = velocity.lerp(
		(Vector2.RIGHT * remap(speed_noise.get_noise_2dv(global_position), -1, 1, 3, 12)).rotated(turn_noise.get_noise_2dv(global_position) * PI * 2),
		1 - 0.000001 ** delta
	)
	global_position += velocity * delta
	var bounds_rect := (get_tree().get_first_node_in_group(&"bounds_rect") as Control).get_global_rect()
	bounds_rect = bounds_rect.grow(28)
	if !bounds_rect.has_point(global_position):
		bounds_rect = bounds_rect.grow(-2)
		global_position.x = wrapf(global_position.x, bounds_rect.position.x, bounds_rect.end.x)
		global_position.y = wrapf(global_position.y, bounds_rect.position.y, bounds_rect.end.y)
		velocity = global_position.direction_to(bounds_rect.get_center()) * 12
		reset_physics_interpolation()

func _on_area_entered(area: Area2D) -> void:
	if area is Hook:
		area.delete()
		points += 1
