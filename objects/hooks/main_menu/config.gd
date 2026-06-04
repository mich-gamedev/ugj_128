extends Node

@export var hook: Hook

#TODO: Set up a pause / config menu

func _ready() -> void:
	hook.collected.connect(_collected)

func _collected() -> void:
	print("No config yet :[")
	await get_tree().create_timer(0.15).timeout
	var inst := (load(owner.scene_file_path) as PackedScene).instantiate()
	inst.position = Vector2(208, 50)
	get_tree().current_scene.add_child(inst)
