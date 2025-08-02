extends Node

var current_level: int = 1
var score: int = 0
var highscores: Dictionary = {}
var base_bpm: float = 120.0
var bpm_increase_per_level: float = 12.0
var bpm: float = 120.0
var beat_duration: float = 0.5  # 60/BPM

# Level pattern data - each level has kick, snare, and hihat patterns
var level_patterns = {
	1: {
		"kick": [true, false, false, false, true, false, false, false],
		"snare": [false, false, true, false, false, false, true, false],
		"hihat": [false, true, false, true, false, true, false, true]
	},
	2: {
		# Four-on-the-floor kick, backbeat snare, offbeat hihat
		"kick": [true, false, true, false, true, false, true, false],
		"snare": [false, false, true, false, false, false, true, false],
		"hihat": [false, true, false, false, false, true, false, false]
	},
	3: {
		# Syncopated kick, ghost note snare, 16th note hihat feel
		"kick": [true, false, false, true, false, false, true, false],
		"snare": [false, true, true, false, false, true, true, false],
		"hihat": [true, true, true, true, true, true, true, true]
	},
	4: {
		# Complex breakbeat pattern
		"kick": [true, false, false, true, false, true, false, false],
		"snare": [false, false, true, false, true, false, true, true],
		"hihat": [true, false, true, true, false, true, false, true]
	}
}


func calculate_beat_duration():
	beat_duration = 60.0 / bpm


func update_bpm_for_level(level: int):
	bpm = base_bpm + ((level - 1) * bpm_increase_per_level)
	calculate_beat_duration()
	print("Level ", level, " BPM: ", bpm)


func get_pattern_for_level(level: int, drum_type: String) -> Array:
	if level_patterns.has(level) and level_patterns[level].has(drum_type):
		return level_patterns[level][drum_type]
	# Default to level 1 pattern if not found
	return level_patterns[1][drum_type]
