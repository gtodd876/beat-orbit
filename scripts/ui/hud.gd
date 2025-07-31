extends CanvasLayer

var score: int = 0
var combo: int = 0
var max_combo: int = 0

@onready var beat_indicator = $HUD/BeatIndicator
@onready var score_label = $HUD/ScoreLabel
@onready var pattern_grid = $HUD/PatternGridContainer
@onready var position_label = $HUD/PositionLabel
@onready var controls_label = $HUD/ControlsLabel
@onready var instructions_label = $HUD/InstructionsLabel


func _ready():
	# Connect to drum wheel signals when the game starts
	var drum_wheel = get_node("/root/Game/DrumWheel")
	if drum_wheel:
		drum_wheel.drum_hit.connect(_on_drum_hit)
		drum_wheel.beat_played.connect(_on_beat_played)
		drum_wheel.pattern_complete.connect(_on_pattern_complete)

	update_score_display()
	update_instructions()
	update_pattern_grid()
	update_position_label(0)


func _on_drum_hit(_drum_type, timing_quality, _beat_position):
	match timing_quality:
		"PERFECT":
			score += int(100 * (1.0 + float(combo) / 10.0))
			combo += 1
		"GOOD":
			score += int(50 * (1.0 + float(combo) / 10.0))
			combo += 1
		"MISS":
			combo = 0

	if combo > max_combo:
		max_combo = combo

	update_score_display()
	show_hit_feedback(timing_quality)

	# Update pattern grid when a hit is registered
	if timing_quality != "MISS":
		update_pattern_grid()


func _on_beat_played(position):
	# Pulse the beat indicator
	if beat_indicator:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(beat_indicator, "modulate", Color(1, 1, 1, 1), 0.05)
		tween.tween_property(beat_indicator, "modulate", Color(0.5, 0.5, 0.5, 1), 0.2)

	# Update beat cursor position
	update_beat_cursor(position)

	# Update position label
	update_position_label(position)


func _on_pattern_complete():
	# Update pattern grid with the current pattern
	update_pattern_grid()


func update_score_display():
	if score_label:
		score_label.text = "Score: %d\nCombo: %d" % [score, combo]


func show_hit_feedback(timing_quality):
	# Create temporary label for hit feedback
	var feedback_label = Label.new()
	feedback_label.text = timing_quality

	match timing_quality:
		"PERFECT":
			feedback_label.modulate = Color(0, 1, 1)  # Cyan
		"GOOD":
			feedback_label.modulate = Color(1, 1, 0)  # Yellow
		"MISS":
			feedback_label.modulate = Color(1, 0, 0)  # Red

	feedback_label.position = get_viewport().get_mouse_position()
	$HUD.add_child(feedback_label)

	# Animate feedback
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback_label, "position:y", feedback_label.position.y - 50, 0.5)
	tween.tween_property(feedback_label, "modulate:a", 0, 0.5)
	tween.finished.connect(func(): feedback_label.queue_free())


func update_instructions():
	if instructions_label:
		instructions_label.text = "Hit SPACE when arrows enter the cyan zone!"
	if controls_label:
		controls_label.text = "[SPACE] Hit Drum | [ESC] Pause | [R] Restart"


func update_pattern_grid():
	var drum_wheel = get_node("/root/Game/DrumWheel")
	if not drum_wheel or not pattern_grid:
		return

	pattern_grid.update_pattern(drum_wheel.current_pattern)


func update_beat_cursor(position):
	if pattern_grid:
		pattern_grid.update_cursor(position)


func update_position_label(position):
	if not position_label:
		return

	# Calculate bar and beat (1-indexed)
	var bar = (position / 4) + 1
	var beat = (position % 4) + 1
	position_label.text = "Bar %d, Beat %d" % [bar, beat]
