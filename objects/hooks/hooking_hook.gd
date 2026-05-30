extends DraggableHook

@onready var timer: Timer = $Timer

func _can_hook() -> bool:
	return get_total_connected_hooks().size() < 5

func _timeout() -> void:
	timer.start(randf_range(3, 20))
	var possible_hooks = get_tree().get_nodes_in_group(&"hook")
	possible_hooks = possible_hooks.filter(func(i): return i != self and !hooks.has(i))
	if possible_hooks.size() > 0:
		Hook.add_hook(self, possible_hooks.pick_random())
