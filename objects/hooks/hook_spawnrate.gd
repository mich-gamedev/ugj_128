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
