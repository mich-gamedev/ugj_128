class_name HookSpawnrate extends Resource
@export_group("Visual")
@export var name: String
@export_multiline var desc: String
@export var icon_20_x_20: PackedScene
@export var main_color: Color
@export var sort_order: int
@export_group("Logic")
@export var scene: PackedScene
@export var spawnrate: Curve
@export_group("Pooling")
@export var default_count: int

func make_defaults() -> void:
	for i in default_count:
		make_hook(true)

func get_hook() -> Hook:
	if Hook.pool.get(self, []).is_empty():
		return make_hook(false)
	var pooled := (Hook.pool[self][0] as Hook).unstash()
	return pooled if pooled else make_hook(false)

func make_hook(stashed: bool) -> Hook:
	var inst := scene.instantiate() as Hook
	inst.spawnrate = self
	if stashed:
		inst.stash()
	else:
		World.world.add_child(inst)
	return inst
