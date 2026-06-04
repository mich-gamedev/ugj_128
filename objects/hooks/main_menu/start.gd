extends Node

@export var hook: Hook

@onready var hint_timer: Timer = $HintTimer
@onready var hint_label: Label = %DragToRaftLabel

func _ready() -> void:
	hook.collected.connect(_collected)
	if hook is DraggableHook:
		hook.drag_started.connect(_drag_started)
		hook.drag_ended.connect(_drag_ended)

func _collected() -> void:
	GameStats.state = GameStats.IN_GAME
	owner.remove_from_group(&"hook")
	get_tree().call_group(&"hook", &"delete")

func _drag_started() -> void:
	hint_timer.start()

func _drag_ended() -> void:
	if !hint_timer.is_stopped():
		hint_label.show()
		await get_tree().create_timer(1.5).timeout
		hint_label.hide()
