extends DraggableHook


var rays: Dictionary[Hook, RayCast2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drag_started.connect(_drag_start)
	drag_ended.connect(_drag_end)
	connect_to_roses()

func connect_to_roses() -> void:
	for i: Hook in get_tree().get_nodes_in_group(&"barbed_hook"):
		if i == self or !is_instance_valid(i) or hooks.has(i): continue
		Hook.add_hook(self, i)
		var ray := RayCast2D.new()
		ray.collide_with_areas = true
		ray.collide_with_bodies = false
		ray.add_exception(self)
		ray.add_exception(i)
		ray.collision_mask = 1 << 4
		ray.enabled = false
		rays[i] = ray
		add_child(ray)
		await get_tree().create_timer(0.1).timeout

func _physics_process(delta: float) -> void:
	super(delta)
	for i in rays.keys():
		if !is_instance_valid(i):
			continue
		var ray := rays[i]
		ray.target_position = to_local(i.global_position)
		ray.force_raycast_update()
		if ray.is_colliding() and ray.get_collider() is DraggableHook:
			var hook := ray.get_collider() as DraggableHook
			hook.end_drag()

func _drag_start() -> void:
	main_color = Color("#ed8796")

func _drag_end() -> void:
	main_color = Color("d20f39")


func _on_timer_timeout() -> void:
	connect_to_roses()
