extends Node

var active: bool

var money: int
var points_needed: int
var points: int

signal started
signal points_collected(amount: int)
signal wave_ended

func start():
	active = true
	started.emit()
	start_wave()

func start_wave():
	points_needed += randi_range(60, 120)

func increment_points(amount: int) -> void:
	points += amount
	money += amount
	points_collected.emit(amount)
