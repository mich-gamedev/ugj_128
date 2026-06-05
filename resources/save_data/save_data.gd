class_name SaveData extends Resource

@export_group("Game")
@export var high_score : StatsPack
@export_group("Audio")
@export var vol_sfx := .75:
	set(v):
		vol_sfx = v
		AudioServer.set_bus_volume_linear(2, v)
@export var vol_music := .75:
	set(v):
		vol_music = v
		AudioServer.set_bus_volume_linear(1, v)
@export var do_filter_effect := true
@export_group("Video")
@export var fullscreen: bool = false:
	set(v):
		fullscreen = v
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if v else DisplayServer.WINDOW_MODE_WINDOWED)
@export var vsync: bool = true:
	set(v):
		vsync = v
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if v else DisplayServer.VSYNC_DISABLED)
@export var show_fps: bool = true:
	set(v):
		show_fps = v
		if is_instance_valid((Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"fps_label") as Label):
			((Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"fps_label") as Label).visible = v

const PATH := "user://save.tres"

static var data: SaveData:
	get:
		if !data:
			if ResourceLoader.exists(PATH):
				data = load(PATH).duplicate_deep()
			else:
				data = new()
		return data

static func save() -> void:
	ResourceSaver.save(data, PATH)
