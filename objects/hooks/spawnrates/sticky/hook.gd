extends DraggableHook

@onready var anim: AnimationPlayer = $Sprite/AnimationPlayer2

var hooked_count := 0
const MAX_HOOKS := 50

func _can_hook(hook: Hook) -> bool:
	return hooked_count < MAX_HOOKS

func _on_area_entered(area: Area2D) -> void:
	if area is Hook:
		if can_hook(area):
			Hook.add_hook(self, area)
			hooked_count += 1
			anim.play(&"RESET")
			anim.queue(&"hook")
		elif anim.assigned_animation != &"die": anim.play(&"die")
