class_name GameStats extends Object

static var pack : StatsPack

static func start_new() -> void:
	if pack:
		if (!SaveData.data.high_score) or (SaveData.data.high_score.total_points < pack.total_points):
			const EMPTY_ARRAY_FUCK_GODOT : Array[String] = []
			var discoveries := SaveData.data.high_score.discoveries if SaveData.data.high_score else EMPTY_ARRAY_FUCK_GODOT
			SaveData.data.high_score = pack.duplicate()
			SaveData.data.high_score.discoveries = discoveries
		for i in pack.discoveries:
			if !SaveData.data.high_score.discoveries.has(i):
				SaveData.data.high_score.discoveries.append(i)
	SaveData.save()
	pack = StatsPack.new()

enum {
	MAIN_MENU,
	IN_GAME,
	GAME_OVER
}

class Signals:
	signal state_changed(new: int)
static var signals = Signals.new()

static var state: int = MAIN_MENU:
	set(v):
		if v == state: return
		state = v
		signals.state_changed.emit(v)
