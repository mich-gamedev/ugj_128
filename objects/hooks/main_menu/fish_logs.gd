extends Node

@export var hook: Hook

const FISH_LOGS = preload("uid://dvuskuiv7tu2s")

func _ready() -> void:
	hook.collected.connect(_collected)

func _collected() -> void:
	await get_tree().create_timer(0.15).timeout
	get_tree().current_scene.add_child(FISH_LOGS.instantiate())
	var inst := (load(owner.scene_file_path) as PackedScene).instantiate()
	inst.position = Vector2(48, 128)
	get_tree().current_scene.add_child(inst)
