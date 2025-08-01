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
		drum_wheel.layer_complete.connect(_on_layer_complete)
		drum_wheel.level_started.connect(_on_level_started)

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

	# Show completion message
	show_completion_message("PATTERN COMPLETE!")

	# Update instructions
	if instructions_label:
		instructions_label.text = "Press SPACE for next level!"


func _on_layer_complete(drum_type):
	# Show layer completion
	var layer_name = ""
	match drum_type:
		0:  # KICK
			layer_name = "KICK LAYER"
		1:  # SNARE
			layer_name = "SNARE LAYER"
		2:  # HIHAT
			layer_name = "HI-HAT LAYER"

	show_completion_message(layer_name + " COMPLETE!")


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
		instructions_label.text = "Hit SPACE when the arrow points to the beat circles!"
	if controls_label:
		controls_label.text = "[SPACE] Hit Drum | [ESC] Pause | [R] Restart"


func update_pattern_grid():
	var drum_wheel = get_node("/root/Game/DrumWheel")
	if not drum_wheel or not pattern_grid:
		return

	# Create pattern array in the format expected by pattern grid
	var display_pattern = []
	for i in range(8):
		display_pattern.append([])

	# Add completed beats to the pattern
	for drum_layer in drum_wheel.completed_layers:
		if drum_wheel.completed_layers[drum_layer]:
			var player_pattern = drum_wheel.player_pattern[drum_layer]
			for beat_idx in range(8):
				if player_pattern[beat_idx]:
					display_pattern[beat_idx].append(drum_layer)

	# Also add current layer's successful hits
	var current_player_pattern = drum_wheel.player_pattern[drum_wheel.current_layer]
	for beat_idx in range(8):
		if current_player_pattern[beat_idx]:
			if not drum_wheel.current_layer in display_pattern[beat_idx]:
				display_pattern[beat_idx].append(drum_wheel.current_layer)

	pattern_grid.update_pattern(display_pattern)


func update_beat_cursor(beat_position):
	if pattern_grid:
		pattern_grid.update_cursor(beat_position)


func update_position_label(position):
	if not position_label:
		return

	# Show beat 1-8
	position_label.text = "Beat %d" % [position + 1]


func show_completion_message(message: String):
	# Create a big centered message with background
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.size = Vector2(600, 120)
	container.position = Vector2(-300, -60)

	# Add background panel
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.add_child(bg)

	# Add text
	var completion_label = Label.new()
	completion_label.text = message
	completion_label.add_theme_font_size_override("font_size", 48)
	completion_label.modulate = Color(0, 1, 1)  # Cyan
	completion_label.set_anchors_preset(Control.PRESET_CENTER)
	completion_label.position = Vector2(-250, -30)
	container.add_child(completion_label)

	$HUD.add_child(container)

	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(container, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(container, "modulate:a", 0, 2.5).set_delay(1.0)
	tween.finished.connect(func(): container.queue_free())


func _on_level_started():
	# Reset instructions for new level
	update_instructions()
	update_pattern_grid()
