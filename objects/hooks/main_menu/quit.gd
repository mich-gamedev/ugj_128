extends Node

@export var hook: Hook

func _ready() -> void:
	hook.collected.connect(_collected)

func _collected() -> void:
	get_tree().quit()
