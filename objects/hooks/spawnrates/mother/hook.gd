extends DraggableHook

var max_children := randi_range(10, 24)

const NO_DRAG_HOOK = preload("uid://cp8pfn8n8kb5k")

@onready var birth_timer: Timer = %BirthTimer

func _physics_process(delta: float) -> void:
	super(delta)
	if birth_timer.is_stopped() and hooks.size() == 0:
		birth_timer.start()

func _on_birth_timer_timeout() -> void:
	if hooks.size() < max_children:
		var inst := NO_DRAG_HOOK.instantiate() as Hook
		inst.cost = 3
		inst.sep_force = 6
		get_tree().current_scene.add_child(inst)
		get_tree().current_scene.move_child(inst, get_index() - 1)
		inst.global_position = global_position
		inst.reset_physics_interpolation()
		Hook.add_hook(self, inst)
	else:
		birth_timer.stop()
