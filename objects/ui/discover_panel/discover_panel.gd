extends PanelContainer

var hook: HookSpawnrate

@onready var title: Label = %Title
@onready var icon_container: ColorRect = %IconContainer
@onready var description: Label = %Description

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.text = "+ " + hook.name.to_upper()
	description.text = hook.desc
	var icon := hook.icon_20_x_20.instantiate() as Control
	icon_container.add_child(icon)
	(get_theme_stylebox(&"panel") as StyleBoxFlat).border_color = hook.main_color
	(title.get_theme_stylebox(&"normal") as StyleBoxFlat).border_color = hook.main_color
