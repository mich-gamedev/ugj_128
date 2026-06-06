extends DraggableHook

const FX = preload("uid://ba1hkjk3x2qcx")
@onready var anim: AnimationPlayer = %Anim

func _physics_process(delta: float) -> void:
	super(delta)
	anim.play(&"fragile" if velocity.length() > 72 else &"RESET")

func _on_area_entered(area: Area2D) -> void:
	if area is Hook:
		if (velocity - area.velocity).length() > 128:
			var inst := FX.instantiate() as RingDraw
			get_tree().current_scene.add_child(inst)
			inst.global_position = global_position
			inst.reset_physics_interpolation()
			queue_free()
