extends CanvasLayer

var score: int = 0
var combo: int = 0
var max_combo: int = 0
var active_beat_cells: Array = []  # Store references to active beat cell sprites
var current_completion_message = null  # Track current completion message

@onready var score_label = $HUD/MarginContainer2/HBoxContainer2/VBoxContainer/Score
@onready var combo_label = $HUD/MarginContainer2/HBoxContainer2/VBoxContainer2/Combo
# PatternGridContainer doesn't exist in scene - removed reference
@onready var position_label = $HUD/PositionLabel
@onready var controls_label = $HUD/MarginContainer/VBoxContainer2/ControlsLabel
@onready var instructions_label = $HUD/MarginContainer/VBoxContainer2/InstructionsLabel
@onready var pattern_grid_node = get_node("/root/Game/PatternGrid")
@onready var beat_marker = get_node("/root/Game/PatternGrid/BeatMarker")
@onready var active_cell_template = get_node("/root/Game/PatternGrid/ActiveCell")


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

	# Hide the template active cell
	if active_cell_template:
		active_cell_template.visible = false


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
	# Update beat cursor position
	update_beat_cursor(position)

	# Update position label
	update_position_label(position)

	# Play sounds from pattern grid
	play_pattern_sounds_at_beat(position)

	# Light up the current beat cells
	light_up_beat_cells(position)


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
		score_label.text = "Score: %d" % [score]
	if combo_label:
		combo_label.text = "Combo: %d" % [combo]


func show_hit_feedback(timing_quality):
	# Don't show feedback for misses
	if timing_quality == "MISS":
		return

	# Create temporary label for hit feedback
	var feedback_label = Label.new()
	feedback_label.text = timing_quality

	match timing_quality:
		"PERFECT":
			feedback_label.modulate = Color(0, 1, 1)  # Cyan
		"GOOD":
			feedback_label.modulate = Color(1, 1, 0)  # Yellow

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
		instructions_label.text = "Hit SPACE when the arrow points to the targets!"
	if controls_label:
		controls_label.text = "[SPACE] Hit Drum | [ESC] Pause | [R] Restart"


func update_pattern_grid():
	var drum_wheel = get_node("/root/Game/DrumWheel")

	if not drum_wheel:
		return

	# Clear existing active cells
	for cell in active_beat_cells:
		cell.queue_free()
	active_beat_cells.clear()

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


	# Create visual beat cells - only if pattern grid nodes exist
	if active_cell_template and pattern_grid_node:
		# Use same positioning as beat marker
		var cell_width = 72
		var cell_height = 102  # Approximate height between rows
		var start_x = 700  # Same as beat marker start
		var start_y = 290  # Y position for K row

		# Create cells for each active beat
		for beat_idx in range(8):
			for layer_idx in range(display_pattern[beat_idx].size()):
				var drum_type = display_pattern[beat_idx][layer_idx]

				var new_cell = active_cell_template.duplicate()
				new_cell.visible = true

				# Position based on beat and drum type
				new_cell.position.x = start_x + (beat_idx * cell_width)
				new_cell.position.y = start_y + (drum_type * cell_height)

				# Don't modify colors - use original sprite colors

				pattern_grid_node.add_child(new_cell)
				active_beat_cells.append(new_cell)


func update_beat_cursor(beat_position):
	# Move the visual beat marker - only if nodes exist
	if beat_marker and pattern_grid_node:
		# Position beat marker based on current beat
		# Beat 1 starts at (703, 546) and moves +72 pixels per beat
		var cell_width = 72  # Exact spacing between beats
		var start_x = 703  # Beat 1 position
		var marker_y = 190  # Now the top row

		beat_marker.position.x = start_x + (beat_position * cell_width)
		beat_marker.position.y = marker_y


func update_position_label(position):
	if not position_label:
		return

	# Show beat 1-8
	position_label.text = "Beat %d" % [position + 1]


func show_completion_message(message: String):
	# Remove any existing completion message
	if current_completion_message and is_instance_valid(current_completion_message):
		current_completion_message.queue_free()

	# Don't show layer complete messages if pattern is already complete
	var is_layer_complete = message.ends_with("LAYER COMPLETE!")
	var is_pattern_done = instructions_label.text == "Press SPACE for next level!"
	if is_layer_complete and is_pattern_done:
		return

	# Create a big centered message with background
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.size = Vector2(600, 120)
	container.position = Vector2(-300, -60)
	current_completion_message = container

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
	tween.finished.connect(func():
		if is_instance_valid(container):
			container.queue_free()
		if current_completion_message == container:
			current_completion_message = null
	)


func _on_level_started():
	# Reset instructions for new level
	update_instructions()
	update_pattern_grid()


func play_pattern_sounds_at_beat(beat_position: int):
	var drum_wheel = get_node("/root/Game/DrumWheel")
	if not drum_wheel:
		return

	# Play all sounds that have been successfully placed in the pattern grid
	for drum_layer in drum_wheel.player_pattern:
		if drum_wheel.player_pattern[drum_layer][beat_position]:
			play_drum_sound(drum_layer)


func play_drum_sound(drum_type):
	# Play drum sounds through audio players
	var audio_players = get_node("/root/Game/AudioPlayers")
	if not audio_players:
		return

	match drum_type:
		0:  # KICK
			var kick_player = audio_players.get_node("KickPlayer")
			if kick_player and kick_player.stream:
				kick_player.play()
		1:  # SNARE
			var snare_player = audio_players.get_node("SnarePlayer")
			if snare_player and snare_player.stream:
				snare_player.play()
		2:  # HIHAT
			var hihat_player = audio_players.get_node("HiHatPlayer")
			if hihat_player and hihat_player.stream:
				hihat_player.play()


func light_up_beat_cells(beat_position: int):
	# Light up cells in the current beat column
	for cell in active_beat_cells:
		# Check if this cell is in the current beat column
		if pattern_grid_node and active_cell_template:
			var cell_width = 72
			var start_x = 703
			var beat_x = start_x + (beat_position * cell_width)

			# Check if cell is in this beat column (within tolerance)
			if abs(cell.position.x - beat_x) < 10:
				# Flash the cell
				var tween = create_tween()
				var original_modulate = cell.modulate
				cell.modulate = Color(0, 1, 1)  # Cyan flash
				tween.tween_property(cell, "modulate", original_modulate, 0.2)
