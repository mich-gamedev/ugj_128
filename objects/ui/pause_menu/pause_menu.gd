extends CanvasLayer

@onready var reset_video: Button = %ResetVideo
@onready var fullscreen: Button = %Fullscreen
@onready var vsync: Button = %Vsync
@onready var reset_audio: Button = %ResetAudio
@onready var music: HSlider = %Music
@onready var sfx: HSlider = %Sfx
@onready var filter_effect: Button = %FilterEffect
@onready var anim: AnimationPlayer = %Anim
@onready var show_fps: Button = %ShowFPS

var default := SaveData.new()

func _ready() -> void:
	fullscreen.set_pressed_no_signal(SaveData.data.fullscreen)
	vsync.set_pressed_no_signal(SaveData.data.vsync)
	music.set_value_no_signal(SaveData.data.vol_music)
	sfx.set_value_no_signal(SaveData.data.vol_sfx)
	filter_effect.set_pressed_no_signal(SaveData.data.do_filter_effect)
	show_fps.set_pressed_no_signal(SaveData.data.show_fps)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		if anim.assigned_animation != &"open": pause()
		else: unpause()
	elif event.is_action_pressed(&"toggle_fullscreen"):
		fullscreen.button_pressed = !fullscreen.button_pressed

func unpause() -> void:
	if anim.assigned_animation == &"open":
		anim.play(&"close")
	get_tree().paused = false
	SaveData.save()

func pause() -> void:
	get_tree().paused = true
	anim.play(&"open")

func _reset_video() -> void:
	fullscreen.button_pressed = default.fullscreen
	vsync.button_pressed = default.vsync
	show_fps.button_pressed = default.show_fps

func _fullscreen(toggled_on: bool) -> void:
	SaveData.data.fullscreen = toggled_on

func _vsync(toggled_on: bool) -> void:
	SaveData.data.vsync = toggled_on

func _reset_audio() -> void:
	music.value = default.vol_music
	sfx.value = default.vol_sfx
	filter_effect.button_pressed = default.do_filter_effect

func _music(value: float) -> void:
	SaveData.data.vol_music = value

func _sfx(value: float) -> void:
	SaveData.data.vol_sfx = value

func _filter_effect(toggled_on: bool) -> void:
	SaveData.data.do_filter_effect = toggled_on

func _click_off(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			unpause()

func _show_fps(toggled_on: bool) -> void:
	SaveData.data.show_fps = toggled_on
