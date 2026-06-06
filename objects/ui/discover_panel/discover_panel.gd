class_name DiscoverPanel extends Panel

@export var hook: HookSpawnrate
var discovered := true

@onready var title: Label = %Title
@onready var icon_container: ColorRect = %IconContainer
@onready var description: Label = %Description
@onready var border_saver: Panel = %BorderSaver
@onready var anim: AnimationPlayer = %Anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(.4 + (.15 * get_index())).timeout
	if discovered:
		title.text = "+ " + hook.name.to_upper()
		description.text = hook.desc
		var icon := hook.icon_20_x_20.instantiate() as Control
		icon_container.add_child(icon)
		var style_panel := get_theme_stylebox(&"panel").duplicate() as StyleBoxFlat
		style_panel.border_color = hook.main_color
		add_theme_stylebox_override(&"panel", style_panel)
		var style_title := title.get_theme_stylebox(&"normal").duplicate() as StyleBoxFlat
		style_title.bg_color = hook.main_color
		title.add_theme_stylebox_override(&"normal", style_title)
		var style_saver := border_saver.get_theme_stylebox(&"panel").duplicate() as StyleBoxFlat
		style_saver.border_color = hook.main_color
		border_saver.add_theme_stylebox_override(&"panel", style_saver)
	else:
		title.text = "- UNDISCOVERED"
		description.text = "???"
		description.add_theme_color_override(&"font_color", Color("#494d64"))
		var style_panel := get_theme_stylebox(&"panel").duplicate() as StyleBoxFlat
		style_panel.border_color = Color("#494d64")
		add_theme_stylebox_override(&"panel", style_panel)
		var style_title := title.get_theme_stylebox(&"normal").duplicate() as StyleBoxFlat
		style_title.bg_color = Color("#494d64")
		title.add_theme_stylebox_override(&"normal", style_title)
		var style_saver := border_saver.get_theme_stylebox(&"panel").duplicate() as StyleBoxFlat
		style_saver.border_color = Color("#494d64")
		border_saver.add_theme_stylebox_override(&"panel", style_saver)
	anim.play(&"open")
