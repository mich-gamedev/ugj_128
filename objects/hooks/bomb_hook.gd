extends DraggableHook

@onready var anim: AnimationPlayer = %Anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(randf_range(0, 4)).timeout
	anim.play(&"warn")

func _animation_finished(anim_name: StringName) -> void:
	if anim_name == &"warn":
		anim.play(&"explode")
		explode.call_deferred()
	else:
		anim.play(&"warn")

func explode() -> void:
	await get_tree().physics_frame
	var overlaps := sep_area.get_overlapping_areas()
	for i in overlaps:
		if i is Hook:
			if hooks.has(i):
				Hook.remove_hook(self, i)
			for j in i.hooks:
				if j in overlaps:
					Hook.remove_hook(i, j)
			i.velocity = global_position.direction_to(i.global_position) * i.regular_speed * 2.5
