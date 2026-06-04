extends DraggableHook

@onready var data_label: Label = %DataLabel

func _ready() -> void:
	collected.connect(_collected)
	data_label.text %= [
		SaveData.data.high_score.total_points,
		SaveData.data.high_score.quotas,
		Time.get_time_dict_from_unix_time(int(SaveData.data.high_score.time_elapsed)).minute,
		Time.get_time_dict_from_unix_time(int(SaveData.data.high_score.time_elapsed)).second
	]

func _collected() -> void:
	await get_tree().create_timer(0.15).timeout
	var inst := (load(scene_file_path) as PackedScene).instantiate()
	inst.position = Vector2(242, 129)
	get_tree().current_scene.add_child(inst)
