extends CanvasLayer

const DISCOVER_PANEL = preload("uid://dh3w4l4j4274e")
@onready var discoveries: VBoxContainer = %DiscoveriesContainer
@onready var anim: AnimationPlayer = %Anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spawns := Hook.get_hook_spawns().duplicate()
	spawns.sort_custom(func(a: HookSpawnrate, b: HookSpawnrate) -> bool: return a.sort_order < b.sort_order)
	for i in spawns:
		var inst := DISCOVER_PANEL.instantiate() as DiscoverPanel
		inst.hook = i
		inst.discovered = is_instance_valid(SaveData.data.high_score) and i.resource_path in SaveData.data.high_score.discoveries
		discoveries.add_child(inst)


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			anim.play(&"close")


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"close": queue_free()
