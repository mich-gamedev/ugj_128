class_name SaveData extends Resource

@export_group("Game")
@export var high_score : StatsPack
@export_group("Audio")
@export var vol_sfx := .5
@export var vol_music := .5
@export_group("Video")
@export var fullscreen: bool = false

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
