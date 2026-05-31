class_name DraggableHook extends Hook

static var dragged_hook: DraggableHook

signal drag_started
signal drag_ended

func _validate_velocity() -> void:
	if dragged_hook == self:
		velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if dragged_hook != self: return
	if event is InputEventMouseButton:
		if !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			dragged_hook = null
			drag_ended.emit()
			set_collision_layer_value(2, true)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dragged_hook: return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			dragged_hook = self
			drag_started.emit()
			set_collision_layer_value(2, false)

func _physics_process(delta: float) -> void:
	super(delta)
	if dragged_hook == self:
		velocity = (get_global_mouse_position() - global_position) / delta * .5
		global_position = get_global_mouse_position()
