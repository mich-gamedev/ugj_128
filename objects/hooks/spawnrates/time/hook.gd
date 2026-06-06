extends DraggableHook

const EARN_POPUP = preload("uid://c851w1lsmyj2y")

func _collected() -> void:
	Raft.time_left += 10
	var inst := EARN_POPUP.instantiate() as Node2D
	(inst.get_node(^"Label") as RichTextLabel).text = "[font otv='wght=900']+10sec"
	(inst.get_node(^"Label") as RichTextLabel).add_theme_color_override(&"default_color", Color("#7dc4e4"))
	(inst.get_node(^"Label/AnimationPlayer") as AnimationPlayer).speed_scale = .5
	Raft.raft.add_child(inst)
	inst.position = Vector2.from_angle(randf() * TAU) * sqrt(randf_range(0, 625)) # 625 == 25 ** 2
	inst.reset_physics_interpolation()
	inst.z_index = 10
