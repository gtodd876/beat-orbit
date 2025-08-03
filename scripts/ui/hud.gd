extends CanvasLayer

var score: int = 0
var combo: int = 0
var max_combo: int = 0
var active_beat_cells: Array = []  # Store references to active beat cell sprites
var current_completion_message = null  # Track current completion message
var life_sprites: Array = []  # Store references to life indicator sprites

@onready var score_label = $HUD/MarginContainer2/HBoxContainer2/VBoxContainer/Score
@onready var combo_label = $HUD/MarginContainer2/HBoxContainer2/VBoxContainer2/Combo
# PatternGridContainer doesn't exist in scene - removed reference
@onready var position_label = $HUD/PositionLabel
@onready var controls_label = $HUD/MarginContainer/VBoxContainer2/ControlsLabel
@onready var instructions_label = $HUD/MarginContainer/VBoxContainer2/InstructionsLabel
@onready var pattern_grid_node = get_node("/root/Game/PatternGrid")
@onready var beat_marker = get_node("/root/Game/PatternGrid/BeatMarker")
@onready var active_cell_template = get_node("/root/Game/PatternGrid/ActiveCell")
@onready var game_dialog = $GameDialog
@onready var ui_sound_manager = null
@onready var win_music_player: AudioStreamPlayer = null


func _ready():
	# Connect to drum wheel signals when the game starts
	var drum_wheel = get_node("/root/Game/DrumWheel")
	if drum_wheel:
		drum_wheel.drum_hit.connect(_on_drum_hit)
		drum_wheel.beat_played.connect(_on_beat_played)
		drum_wheel.pattern_complete.connect(_on_pattern_complete)
		drum_wheel.layer_complete.connect(_on_layer_complete)
		drum_wheel.level_started.connect(_on_level_started)
		drum_wheel.game_over.connect(_on_game_over)

	if game_dialog:
		game_dialog.continue_pressed.connect(_on_dialog_continue)

	# Make sure score label is visible
	if score_label:
		score_label.visible = true

	# Create lives display
	create_lives_display()

	update_score_display()
	update_instructions()
	update_pattern_grid()
	update_position_label(0)

	# Set initial window title
	var title_text = "Level %d" % GameData.current_level
	get_tree().get_root().title = "Beat Orbit - " + title_text

	# Hide the template active cell
	if active_cell_template:
		active_cell_template.visible = false

	# Set up win music player
	win_music_player = AudioStreamPlayer.new()
	win_music_player.name = "WinMusicPlayer"
	win_music_player.bus = "Music"
	win_music_player.volume_db = -10.0
	add_child(win_music_player)

	# Load win music
	var win_music = load("res://assets/audio/music/win-music.wav")
	if win_music:
		win_music_player.stream = win_music
	else:
		# print("ERROR: Could not load win-music.wav")
		pass

	# Enable input processing for restart key
	set_process_input(true)

	# Try to find UI sound manager
	ui_sound_manager = get_node_or_null("/root/Game/UISoundManager")


func update_lives_display(miss_count: int):
	# Hide life sprites based on miss count
	for i in range(life_sprites.size()):
		if i < miss_count:
			life_sprites[life_sprites.size() - 1 - i].visible = false
		else:
			life_sprites[life_sprites.size() - 1 - i].visible = true


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
			# Update lives display
			var drum_wheel = get_node("/root/Game/DrumWheel")
			if drum_wheel:
				update_lives_display(drum_wheel.miss_count)

	if combo > max_combo:
		max_combo = combo

	update_score_display()
	# Hit feedback is handled by HitFeedbackManager in drum_wheel

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

	# Show level complete dialog
	# print("Pattern complete! Showing dialog...")
	if game_dialog:
		# Check if this was the final level
		if GameData.current_level >= 3:
			# Stop level 3 music and play win music
			var drum_wheel = get_node("/root/Game/DrumWheel")
			if drum_wheel:
				# Stop the drum wheel completely to prevent music restart
				drum_wheel.is_playing = false
				if drum_wheel.music_player:
					# print("Stopping level 3 music...")
					drum_wheel.music_player.stop()
				else:
					# print("ERROR: Could not find music_player")
					pass
			else:
				# print("ERROR: Could not find drum_wheel")
				pass

			# Play win music
			if win_music_player and win_music_player.stream:
				# print("Playing win music...")
				win_music_player.play()
			else:
				# print("ERROR: Could not play win music")
				pass

			game_dialog.show_dialog(game_dialog.DialogType.GAME_WIN, score, combo)
		else:
			game_dialog.show_dialog(game_dialog.DialogType.LEVEL_COMPLETE, score, combo)
	else:
		# print("ERROR: game_dialog is null in _on_pattern_complete!")
		pass


func _on_layer_complete(drum_type):
	# Skip hi-hat layer complete message since level is already complete
	if drum_type == 2:  # HIHAT
		return
	# Show layer completion
	var layer_name = ""
	match drum_type:
		0:  # KICK
			layer_name = "KICK LAYER"
		1:  # SNARE
			layer_name = "SNARE LAYER"

	# Temporarily show layer complete message (will be replaced by dialog animations later)
	show_completion_message(layer_name + " COMPLETE!")


func update_score_display():
	if score_label:
		score_label.text = "Score: %d" % [score]
		# Animate score label
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		score_label.pivot_offset = score_label.size / 2
		tween.tween_property(score_label, "scale", Vector2(1.15, 1.15), 0.1)
		tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.3)

	if combo_label:
		combo_label.text = "Combo: %d" % [combo]
		# Animate combo label with color pulse for milestones
		var tween = create_tween()
		combo_label.pivot_offset = combo_label.size / 2

		if combo > 0 and combo % 10 == 0:  # Milestone every 10 combos
			# Big celebration animation
			tween.set_parallel(true)
			# Play combo milestone sound
			# TEMP: Disabled until proper UI sounds are implemented
			# if ui_sound_manager:
			# 	ui_sound_manager.play_combo_milestone()
			(
				tween
				. tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.15)
				. set_trans(Tween.TRANS_BACK)
				. set_ease(Tween.EASE_OUT)
			)
			tween.tween_property(combo_label, "modulate", Color(1.0, 0.9, 0.2), 0.15)  # Golden flash
			tween.chain().set_parallel(true)
			tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.4).set_trans(
				Tween.TRANS_ELASTIC
			)
			tween.tween_property(combo_label, "modulate", Color.WHITE, 0.4)
		elif combo > 0:
			# Normal combo animation
			tween.tween_property(combo_label, "scale", Vector2(1.1, 1.1), 0.08).set_trans(
				Tween.TRANS_QUAD
			)
			tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(
				Tween.TRANS_ELASTIC
			)

	# Update level display in the title
	var title_text = "Level %d" % GameData.current_level
	get_tree().get_root().title = "Beat Orbit - " + title_text


# Removed show_hit_feedback function - now handled by HitFeedbackManager in drum_wheel


func _input(event):
	if event.is_action_pressed("restart"):
		# Unpause if paused before restarting
		if get_tree().paused:
			get_tree().paused = false
		restart_game()


func create_lives_display():
	# Create a container for lives to the right of combo
	var lives_container = HBoxContainer.new()
	lives_container.name = "LivesContainer"
	lives_container.add_theme_constant_override("separation", 10)

	# Position it to the right of the combo label
	if combo_label and combo_label.get_parent():
		var parent = combo_label.get_parent()
		parent.add_child(lives_container)

		# Add some spacing
		var spacer = Control.new()
		spacer.custom_minimum_size.x = 50
		parent.add_child(spacer)
		parent.move_child(spacer, parent.get_child_count() - 2)

		# Load arrow texture
		var arrow_texture = load("res://assets/art/sprites/arrow-2x.png")

		# Create 3 life indicators
		for i in range(3):
			var life_sprite = TextureRect.new()
			life_sprite.texture = arrow_texture
			life_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			life_sprite.custom_minimum_size = Vector2(30, 30)  # Small size
			life_sprite.modulate = Color(0, 1, 1)  # Cyan color to match UI
			lives_container.add_child(life_sprite)
			life_sprites.append(life_sprite)


func update_instructions():
	if instructions_label:
		instructions_label.text = "Hit SPACE on target to trigger beat on the grid"
	if controls_label:
		controls_label.text = "[ESC] Pause         [R] Restart"


func update_pattern_grid():
	var drum_wheel = get_node("/root/Game/DrumWheel")

	if not drum_wheel:
		return

	# Remove debug logging

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

				# Keep the original small scale from the template

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
	if is_layer_complete and game_dialog and game_dialog.visible:
		return

	# Create a container positioned on the right side
	var container = Control.new()
	container.position = Vector2(550, 300)  # Move left for more padding from edge
	container.size = Vector2(400, 100)
	current_completion_message = container

	# Create panel with message
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 100)
	container.add_child(panel)

	# Set panel background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	# Add text
	var completion_label = Label.new()
	completion_label.text = message
	completion_label.add_theme_font_size_override("font_size", 48)
	completion_label.modulate = Color(0, 1, 1)  # Cyan
	completion_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	completion_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_child(completion_label)

	$HUD.add_child(container)

	# Start with container off to the right and transparent
	container.modulate.a = 0
	container.position.x = 1300  # Start off-screen to the right

	# Animate in with more dramatic effect
	var tween = create_tween()
	tween.set_parallel(true)
	# Fade in and slide from right
	tween.tween_property(container, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(container, "position:x", 550, 0.3).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)
	# Small bounce effect
	tween.chain().tween_property(container, "position:x", 530, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(container, "position:x", 550, 0.1).set_trans(Tween.TRANS_SINE)
	# Fade out after longer delay
	tween.chain().tween_property(container, "modulate:a", 0, 1.0).set_delay(3.0)
	tween.finished.connect(
		func():
			if is_instance_valid(container):
				container.queue_free()
			if current_completion_message == container:
				current_completion_message = null
	)


func _on_level_started():
	# Clear any lingering completion messages
	if current_completion_message and is_instance_valid(current_completion_message):
		current_completion_message.queue_free()
		current_completion_message = null

	# Reset instructions for new level
	update_instructions()
	update_pattern_grid()

	# Update lives display with current miss count
	var drum_wheel = get_node("/root/Game/DrumWheel")
	if drum_wheel:
		update_lives_display(drum_wheel.miss_count)

	# Update window title for new level
	var title_text = "Level %d" % GameData.current_level
	get_tree().get_root().title = "Beat Orbit - " + title_text

	# print("Level started: ", GameData.current_level)


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
				# Simple scale pulse animation without modifying color
				var tween = create_tween()
				var original_scale = cell.scale

				# Very subtle scale pulse - just 5% bigger
				(
					tween
					. tween_property(cell, "scale", original_scale * 1.05, 0.1)
					. set_trans(Tween.TRANS_QUAD)
					. set_ease(Tween.EASE_OUT)
				)
				tween.chain().tween_property(cell, "scale", original_scale, 0.2).set_trans(
					Tween.TRANS_SINE
				)


func _on_game_over():
	# Show game over dialog
	# print("Game Over triggered! Score: ", score, " Combo: ", combo)
	if game_dialog:
		# print("Showing game dialog...")
		game_dialog.show_dialog(game_dialog.DialogType.GAME_OVER, score, combo)
	else:
		# print("ERROR: game_dialog is null!")
		pass


func _on_dialog_continue():
	var drum_wheel = get_node("/root/Game/DrumWheel")
	if not drum_wheel:
		return

	if game_dialog.dialog_type == game_dialog.DialogType.LEVEL_COMPLETE:
		# Update score with combo bonus
		score = game_dialog.final_score
		update_score_display()

		# Advance to next level
		GameData.current_level += 1
		# print("Advancing to level ", GameData.current_level)
		drum_wheel.start_next_level()
	else:
		# Game over or game win - reset everything

		# Stop win music if it's playing
		if win_music_player and win_music_player.playing:
			win_music_player.stop()

		score = 0
		combo = 0
		max_combo = 0
		GameData.current_level = 1
		GameData.update_bpm_for_level(1)  # Reset BPM to level 1
		update_score_display()

		# Reset lives display
		update_lives_display(0)

		# Recalculate rotation speed with reset BPM
		var beat_duration = 60.0 / GameData.bpm
		drum_wheel.rotation_speed = TAU / (beat_duration * 8)
		# Load level 1 patterns before resetting
		drum_wheel.load_level_patterns()
		drum_wheel.reset_game()
		# Clear the pattern grid display
		update_pattern_grid()


func restart_game():
	# Hide dialog if it's showing
	if game_dialog and game_dialog.visible:
		game_dialog.hide_dialog()

	# Stop win music if it's playing
	if win_music_player and win_music_player.playing:
		win_music_player.stop()

	var drum_wheel = get_node("/root/Game/DrumWheel")
	if not drum_wheel:
		return

	# Reset everything
	score = 0
	combo = 0
	max_combo = 0
	GameData.current_level = 1
	GameData.update_bpm_for_level(1)
	update_score_display()

	# Reset lives display
	update_lives_display(0)

	# Recalculate rotation speed with reset BPM
	var beat_duration = 60.0 / GameData.bpm
	drum_wheel.rotation_speed = TAU / (beat_duration * 8)

	# Load level 1 patterns and reset
	drum_wheel.load_level_patterns()
	drum_wheel.reset_game()
	update_pattern_grid()
