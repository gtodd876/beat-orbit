class_name DrumWheel
extends Node2D

# Signals
signal drum_hit(drum_type: DrumType, timing_quality: String, beat_number: int)
signal pattern_complete
signal beat_played(beat_number: int)
signal layer_complete(drum_type: DrumType)
signal level_started
signal game_over

# Drum types
enum DrumType { KICK, SNARE, HIHAT }

# Constants
const PERFECT_WINDOW = 0.05
const GOOD_WINDOW = 0.1
const MISS_WINDOW = 0.15
# New color palette
const BLUE_COLOR = Color(0.2, 0.8, 1.0)  # HSL(196, 99, 66) converted to RGB
const MAGENTA_COLOR = Color(0.85, 0.35, 0.85)  # HSL(303, 67, 51) converted to RGB
const BLACK_COLOR = Color(0.09, 0.09, 0.09)  # HSL(0, 0, 9)
const WHITE_COLOR = Color(1.0, 1.0, 1.0)  # White

# Visual settings
@export var wheel_radius: float = 200.0
@export var beat_circle_radius: float = 30.0
@export var wheel_center_offset: Vector2 = Vector2(-270, 10)  # Offset of the drum wheel sprite

# Audio settings
@export var bpm: float = 120.0

# Pattern data - loaded from GameData based on current level
var kick_pattern: Array = []
var snare_pattern: Array = []
var hihat_pattern: Array = []

# Game state
var current_layer: DrumType = DrumType.KICK
var completed_layers: Dictionary = {
	DrumType.KICK: false, DrumType.SNARE: false, DrumType.HIHAT: false
}
var player_pattern: Dictionary = {
	DrumType.KICK: [false, false, false, false, false, false, false, false],
	DrumType.SNARE: [false, false, false, false, false, false, false, false],
	DrumType.HIHAT: [false, false, false, false, false, false, false, false]
}
var is_pattern_complete: bool = false
var miss_count: int = 0
var max_misses: int = 3

# Rotation state
var arrow_rotation: float = 0.0
var rotation_speed: float = 0.0
var beat_timer: float = 0.0
var current_beat: int = 0
var is_playing: bool = false

# Wild animation state
var is_animating: bool = false
var animation_timer: float = 0.0
var animation_duration: float = 0.0
var animation_type: String = ""
var base_rotation_speed: float = 0.0
var target_rotation: float = 0.0

# Public variables
var hit_targets: Array = []

# Visual elements - @onready variables
@onready var arrow_node = $Arrow
@onready var hit_target_container = $HitTargetContainer
@onready var beat_positions_ring = $Sprite2D  # The magenta circle showing beat positions
@onready var hit_feedback_manager = $HitFeedbackManager
@onready var screen_shake: ScreenShakeManager = null
@onready var ui_sound_manager: UISoundManager = null


func _ready():
	# Update BPM for current level
	GameData.update_bpm_for_level(GameData.current_level)

	# Calculate rotation speed based on BPM
	var beat_duration = 60.0 / GameData.bpm
	base_rotation_speed = TAU / (beat_duration * 8)  # 8 beats per rotation
	rotation_speed = base_rotation_speed

	# Load patterns for current level
	load_level_patterns()

	# Setup hit targets
	setup_hit_targets()

	# Setup arrow with proper offset
	if arrow_node:
		# Set the arrow's offset so it rotates from its bottom
		# This makes it rotate like a clock hand
		arrow_node.offset = Vector2(0, -100)  # Adjust based on arrow sprite size

	# Create hit feedback manager if it doesn't exist
	if not hit_feedback_manager:
		var HfmScene = preload("res://scenes/effects/hit_feedback_manager.tscn")
		hit_feedback_manager = HfmScene.instantiate()
		add_child(hit_feedback_manager)

	# Try to find screen shake manager
	screen_shake = get_node_or_null("/root/Game/ScreenShakeManager")

	# Try to find UI sound manager
	ui_sound_manager = get_node_or_null("/root/Game/UISoundManager")

	# Start playing
	is_playing = true
	update_target_visuals()


func setup_hit_targets():
	# Get the existing hit target or create duplicates as needed
	if hit_target_container and hit_target_container.get_child_count() > 0:
		var template_target = hit_target_container.get_child(0)
		template_target.visible = false  # Hide the template

		# We'll create and position targets as needed based on the current layer
		# For now, just store the reference
		hit_targets.clear()


func _process(delta):
	if not is_playing:
		return

	# Handle wild animations
	if is_animating:
		handle_animation(delta)
	else:
		# Normal rotation
		arrow_rotation += rotation_speed * delta

		# Wrap around
		if arrow_rotation >= TAU:
			arrow_rotation -= TAU
		elif arrow_rotation < 0:
			arrow_rotation += TAU

	# Update arrow visual
	if arrow_node:
		arrow_node.rotation = arrow_rotation
		# Position arrow at the wheel center
		arrow_node.position = wheel_center_offset

		# Make sure arrow has proper offset to point from center
		# The arrow sprite should have its pivot at the center of the wheel
		# and extend outward to the radius

	# Update beat timer
	beat_timer += delta
	# Beat duration would be 60.0 / bpm, but not needed here

	# Check if we've hit a new beat
	var new_beat = int((arrow_rotation + PI / 2) / (TAU / 8)) % 8
	if new_beat != current_beat:
		current_beat = new_beat
		# Only emit beat_played during normal rotation, not during wild animations
		if not is_animating:
			emit_signal("beat_played", current_beat)
		# Don't play sounds here - let the pattern grid handle it


func _input(event):
	if event.is_action_pressed("hit_drum"):
		# Don't process input if not playing or if paused
		if not is_playing or get_tree().paused:
			return

		# Check if game dialog is visible
		var ui = get_node("/root/Game/UI")
		if ui:
			var game_dialog = ui.get_node("GameDialog")
			if game_dialog and game_dialog.visible:
				return

		if is_pattern_complete:
			# When pattern is complete, SPACE advances to next level
			start_next_level()
		elif not is_animating:
			check_hit()


func check_hit():
	# Calculate which beat the arrow is closest to
	# Arrow starts at -PI/2 (12 o'clock) and rotates clockwise
	# We want: Beat 1 at 12 o'clock, Beat 3 at 3 o'clock, Beat 5 at 6 o'clock, Beat 7 at 9 o'clock
	var normalized_angle = wrapf(arrow_rotation + PI / 2, 0, TAU)  # Shift so 12 o'clock = 0
	var beat_angle = TAU / 8
	# Calculate beat index (0-7)
	var raw_beat = int(round(normalized_angle / beat_angle)) % 8
	# Apply offset to align beats correctly (beat 1 at 12 o'clock)
	var closest_beat = (raw_beat - 2 + 8) % 8
	# Calculate timing accuracy
	# The raw_beat value represents the actual angle position
	# We need to use raw_beat for angle calculation, not the offset closest_beat
	var beat_target_angle = (raw_beat * beat_angle) - PI / 2
	var angle_distance = abs(angle_diff(arrow_rotation, beat_target_angle))
	var time_difference = angle_distance / base_rotation_speed

	var timing_quality = ""
	var success = false

	if time_difference <= PERFECT_WINDOW:
		timing_quality = "PERFECT"
		success = true
		# Trigger screen shake for perfect hits
		if screen_shake:
			screen_shake.shake_perfect_hit()
	elif time_difference <= GOOD_WINDOW:
		timing_quality = "GOOD"
		success = true
	else:
		timing_quality = "MISS"
		success = false

	# Check if this beat should be hit for current layer
	var correct_beat = false
	match current_layer:
		DrumType.KICK:
			correct_beat = kick_pattern[closest_beat]
		DrumType.SNARE:
			correct_beat = snare_pattern[closest_beat]
		DrumType.HIHAT:
			correct_beat = hihat_pattern[closest_beat]

	if success and correct_beat:
		# Record successful hit
		player_pattern[current_layer][closest_beat] = true

		# Visual feedback on hit target (if there's one at this position)
		show_hit_feedback_at_beat(closest_beat, timing_quality)

		# Start wild animation
		start_wild_animation(current_layer)

		# Check if layer is complete
		if is_layer_complete(current_layer):
			complete_current_layer()

		# Play drum sound
		play_drum_sound(current_layer)

		# Only emit successful hit signal
		emit_signal("drum_hit", current_layer, timing_quality, closest_beat)
	else:
		# Show miss feedback
		show_hit_feedback_at_beat(closest_beat, "MISS")

		# Play miss sound
		play_miss_sound()

		# Track misses
		miss_count += 1
		if miss_count >= max_misses:
			is_playing = false
			emit_signal("game_over")

		# Emit miss signal
		emit_signal("drum_hit", current_layer, "MISS", closest_beat)


func angle_diff(a1: float, a2: float) -> float:
	var diff = a1 - a2
	while diff > PI:
		diff -= TAU
	while diff < -PI:
		diff += TAU
	return diff


func start_wild_animation(drum_type: DrumType):
	is_animating = true
	animation_timer = 0.0

	match drum_type:
		DrumType.KICK:
			# 1-2 fast full rotations
			animation_type = "kick"
			animation_duration = 0.5
			var spins = randi_range(1, 2)
			var direction = 1 if randf() > 0.5 else -1
			target_rotation = arrow_rotation + (TAU * spins * direction)

		DrumType.SNARE:
			# Multiple random half turns
			animation_type = "snare"
			animation_duration = 0.4
			var half_turns = randi_range(2, 4)
			var direction = 1 if randf() > 0.5 else -1
			target_rotation = arrow_rotation + (PI * half_turns * direction)

		DrumType.HIHAT:
			# Random direction change
			animation_type = "hihat"
			animation_duration = 0.2
			rotation_speed *= -1  # Just reverse direction


func handle_animation(delta: float):
	animation_timer += delta

	if animation_type == "hihat":
		# Hi-hat just reverses direction, no special animation
		arrow_rotation += rotation_speed * delta
		if animation_timer >= animation_duration:
			is_animating = false
			animation_type = ""
	else:
		# Kick and snare animations
		var progress = animation_timer / animation_duration

		if progress >= 1.0:
			# Animation complete, resync to beat
			is_animating = false
			animation_type = ""
			resync_to_beat()
		else:
			# Ease-out animation
			var eased_progress = 1.0 - pow(1.0 - progress, 3)
			var start_rotation = arrow_rotation
			arrow_rotation = lerp(start_rotation, target_rotation, eased_progress * delta * 10)


func resync_to_beat():
	# Find the nearest beat position and smoothly align to it
	var beat_angle = TAU / 8
	var normalized_angle = wrapf(arrow_rotation + PI / 2, 0, TAU)
	var nearest_beat = round(normalized_angle / beat_angle)
	var target_angle = (nearest_beat * beat_angle) - PI / 2

	arrow_rotation = target_angle


func is_layer_complete(layer: DrumType) -> bool:
	var pattern = get_pattern_for_layer(layer)
	for i in range(8):
		if pattern[i] and not player_pattern[layer][i]:
			return false
	return true


func get_pattern_for_layer(layer: DrumType) -> Array:
	match layer:
		DrumType.KICK:
			return kick_pattern
		DrumType.SNARE:
			return snare_pattern
		DrumType.HIHAT:
			return hihat_pattern
	return []


func complete_current_layer():
	completed_layers[current_layer] = true
	emit_signal("layer_complete", current_layer)

	# Trigger screen shake for layer completion
	if screen_shake:
		screen_shake.shake_layer_complete()

	# Play layer complete sound
	if ui_sound_manager:
		ui_sound_manager.play_layer_complete()

	# Move to next layer
	if current_layer == DrumType.KICK:
		current_layer = DrumType.SNARE
		update_target_visuals()
	elif current_layer == DrumType.SNARE:
		current_layer = DrumType.HIHAT
		update_target_visuals()
	elif current_layer == DrumType.HIHAT:
		# All layers complete!
		is_pattern_complete = true
		emit_signal("pattern_complete")
		# Hide all hit targets since pattern is complete
		hide_all_targets()
		# Trigger big screen shake for pattern completion
		if screen_shake:
			screen_shake.shake_pattern_complete()

		# Play pattern complete sound
		if ui_sound_manager:
			ui_sound_manager.play_pattern_complete()


func update_target_visuals():
	# Clear existing hit targets
	for target in hit_targets:
		target.queue_free()
	hit_targets.clear()

	# Get pattern for current layer
	var pattern = get_pattern_for_layer(current_layer)

	# Create hit targets at the beats where they should appear
	if hit_target_container and hit_target_container.get_child_count() > 0:
		var template_target = hit_target_container.get_child(0)

		for i in range(8):
			if pattern[i]:
				# This beat should have a target
				var new_target = template_target.duplicate()
				new_target.visible = true

				# Position it at the correct angle, accounting for the sprite offset
				var angle = (i * TAU / 8) - PI / 2  # Start at top (12 o'clock)
				# Adjust radius slightly to center targets in the black gaps
				var adjusted_radius = wheel_radius - 8  # Fine-tune to center in gaps
				var target_position = Vector2(adjusted_radius, 0).rotated(angle)
				new_target.position = target_position + wheel_center_offset

				# Rotate the target to face outward
				new_target.rotation = angle + PI / 2

				# Store beat number in metadata
				new_target.set_meta("beat_number", i)

				hit_target_container.add_child(new_target)
				hit_targets.append(new_target)

				# Add subtle pulse animation to draw attention
				add_pulse_animation(new_target)


func get_color_for_layer(layer: DrumType) -> Color:
	# Use the new color palette - alternate between blue and magenta
	match layer:
		DrumType.KICK:
			return BLUE_COLOR
		DrumType.SNARE:
			return MAGENTA_COLOR
		DrumType.HIHAT:
			return BLUE_COLOR
	return WHITE_COLOR


func play_drum_sound(drum_type: DrumType):
	# Play drum sounds through audio players
	var audio_players = get_node("/root/Game/AudioPlayers")
	if not audio_players:
		return

	match drum_type:
		DrumType.KICK:
			var kick_player = audio_players.get_node("KickPlayer")
			if kick_player and kick_player.stream:
				kick_player.play()
		DrumType.SNARE:
			var snare_player = audio_players.get_node("SnarePlayer")
			if snare_player and snare_player.stream:
				snare_player.play()
		DrumType.HIHAT:
			var hihat_player = audio_players.get_node("HiHatPlayer")
			if hihat_player and hihat_player.stream:
				hihat_player.play()


func play_miss_sound():
	# Play miss sound effect
	var audio_players = get_node("/root/Game/AudioPlayers")
	if not audio_players:
		return

	var miss_player = audio_players.get_node("MissPlayer")
	if miss_player and miss_player.stream:
		miss_player.play()


func reset_game():
	# Reset all patterns and state
	for layer in player_pattern:
		for i in range(8):
			player_pattern[layer][i] = false

	for layer in completed_layers:
		completed_layers[layer] = false

	current_layer = DrumType.KICK
	arrow_rotation = -PI / 2  # Start at beat 1 (12 o'clock)
	is_animating = false
	is_pattern_complete = false
	miss_count = 0
	is_playing = true
	update_target_visuals()


func start_next_level():
	# Update BPM for new level
	GameData.update_bpm_for_level(GameData.current_level)

	# Recalculate rotation speed with new BPM
	var beat_duration = 60.0 / GameData.bpm
	base_rotation_speed = TAU / (beat_duration * 8)
	rotation_speed = base_rotation_speed

	# Load patterns for the new level
	load_level_patterns()

	# Reset the game state
	reset_game()

	# Let HUD know level has started
	emit_signal("level_started")


func show_hit_feedback_at_beat(beat_number: int, timing_quality: String):
	# Find if there's a hit target at this beat
	for i in range(hit_targets.size()):
		var target = hit_targets[i]
		if target.has_meta("beat_number") and target.get_meta("beat_number") == beat_number:
			# Spawn hit feedback text
			if hit_feedback_manager:
				var feedback_pos = target.global_position
				hit_feedback_manager.spawn_feedback(feedback_pos, timing_quality)

			if timing_quality == "PERFECT" or timing_quality == "GOOD":
				# Spawn particle effect at target position
				spawn_hit_particles_at_position(target.global_position, timing_quality)

				# Remove the target on successful hit
				var tween = create_tween()
				tween.set_parallel(true)
				tween.tween_property(target, "scale", Vector2(1.5, 1.5), 0.2)
				tween.tween_property(target, "modulate:a", 0, 0.2)
				tween.finished.connect(
					func():
						if is_instance_valid(target):
							target.queue_free()
						hit_targets.erase(target)
				)
			else:
				# Flash red for miss - make it more noticeable
				var tween = create_tween()
				var original_modulate = target.modulate
				# Bright red flash
				target.modulate = Color(1.5, 0, 0)  # Bright red
				# Hold red for a moment then fade back
				tween.tween_property(target, "modulate", Color(1, 0, 0), 0.1)  # Quick flash to red
				tween.tween_property(target, "modulate", Color(1, 0, 0), 0.4)  # Hold red
				tween.tween_property(target, "modulate", original_modulate, 0.3)  # Fade back
			break


func hide_all_targets():
	for target in hit_targets:
		target.visible = false


func spawn_hit_particles_at_position(pos: Vector2, timing_quality: String):
	# Create particles at the Game level to ensure they render on top
	var game_node = get_node("/root/Game")
	if not game_node:
		return

	# Load particle scene
	var particles = preload("res://scenes/effects/hit_particles.tscn").instantiate()

	# Configure particle properties
	particles.emitting = true
	particles.position = pos
	particles.z_index = 1000  # Very high z-index to ensure it's on top

	# Use only disc particle for now
	particles.texture = preload("res://assets/art/sprites/particle-disc.png")

	# Set color based on current drum layer
	var particle_color = get_color_for_layer(current_layer)
	particle_color = particle_color.lightened(0.3)  # Slightly less bright for custom sprites
	particles.modulate = particle_color

	# Calculate direction away from drum wheel center
	var drum_center = global_position + wheel_center_offset
	var direction_away = (pos - drum_center).normalized()

	# Adjust particle properties based on timing quality
	var proc_material = particles.process_material as ParticleProcessMaterial
	if proc_material:
		# Set direction to spray outward from the drum
		proc_material.direction = Vector3(direction_away.x, direction_away.y, 0)
		proc_material.spread = 15.0  # Narrow spread for focused burst

		match timing_quality:
			"PERFECT":
				proc_material.scale_min = 0.1
				proc_material.scale_max = 0.3
				proc_material.initial_velocity_min = 400.0
				proc_material.initial_velocity_max = 700.0
				particles.amount = 25
				particles.lifetime = 0.8
			"GOOD":
				proc_material.scale_min = 0.08
				proc_material.scale_max = 0.2
				proc_material.initial_velocity_min = 300.0
				proc_material.initial_velocity_max = 500.0
				particles.amount = 15
				particles.lifetime = 0.6

	# Add to game and auto-remove after emission
	game_node.add_child(particles)

	# Remove particles after they finish
	await particles.finished
	particles.queue_free()


func add_pulse_animation(target: Node2D):
	# Create a looping pulse animation for the target
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)

	# Store original scale
	var original_scale = target.scale

	# Pulse between original and slightly larger - more subtle
	tween.tween_property(target, "scale", original_scale * 1.08, 0.8).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, "scale", original_scale, 0.8).set_ease(Tween.EASE_IN_OUT)

	# Store tween reference so we can stop it later
	target.set_meta("pulse_tween", tween)


func load_level_patterns():
	# Load patterns from GameData based on current level
	print("Loading patterns for level ", GameData.current_level)
	kick_pattern = GameData.get_pattern_for_level(GameData.current_level, "kick")
	snare_pattern = GameData.get_pattern_for_level(GameData.current_level, "snare")
	hihat_pattern = GameData.get_pattern_for_level(GameData.current_level, "hihat")
	print("Kick pattern: ", kick_pattern)
	print("Snare pattern: ", snare_pattern)
	print("Hi-hat pattern: ", hihat_pattern)
