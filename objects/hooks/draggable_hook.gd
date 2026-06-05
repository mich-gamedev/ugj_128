class_name DraggableHook extends Hook

@export_range(0, 1, 0.01, "or_greater") var throw_velocity_ratio: float = .5

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
			end_drag()

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dragged_hook: return
	if _is_deleting: return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			start_drag()

func start_drag() -> void:
	dragged_hook = self
	drag_started.emit()
	set_collision_layer_value(2, false)
	set_collision_layer_value(5, true)

func end_drag() -> void:
	dragged_hook = null
	drag_ended.emit()
	set_collision_layer_value(2, true)
	set_collision_layer_value(5, false)

func _physics_process(delta: float) -> void:
	super(delta)
	if dragged_hook == self:
		var bounds := get_tree().get_first_node_in_group(&"bounds_rect").get_global_rect() as Rect2
		velocity = (get_global_mouse_position() - global_position) / delta * throw_velocity_ratio
		global_position = get_global_mouse_position().clamp(bounds.position, bounds.end)
