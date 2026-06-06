extends Node2D

@export var hook: Hook

@onready var sfx_added: AudioStreamPlayer2D = $HookAddedSFX
@onready var sfx_removed: AudioStreamPlayer2D = $HookRemovedSFX
@onready var sfx_drag_start: AudioStreamPlayer2D = $DragStartedSFX
@onready var sfx_drag_end: AudioStreamPlayer2D = $DragEndedSFX
@onready var sfx_sliced: AudioStreamPlayer2D = $SlicedSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hook.hooked.connect(func(_other: Hook) -> void: sfx_added.play())
	hook.hook_detatched_from.connect(func(_other: Hook) -> void: sfx_removed.play())
	hook.sliced.connect(sfx_sliced.play)
	if hook is DraggableHook:
		hook.drag_started.connect(func() -> void: sfx_drag_start.play())
		hook.drag_ended.connect(func() -> void: sfx_drag_end.play())
