extends Node

var current_level: int = 1
var score: int = 0
var highscores: Dictionary = {}
var bpm: float = 120.0
var beat_duration: float = 0.5  # 60/BPM


func calculate_beat_duration():
	beat_duration = 60.0 / bpm
