class_name DrumWheel
extends Node2D

# Signals
signal drum_hit(drum_type: DrumType, timing_quality: String, beat_number: int)
signal pattern_complete
signal beat_played(beat_number: int)
signal layer_complete(drum_type: DrumType)
signal level_started

# Drum types
enum DrumType { KICK, SNARE, HIHAT }

# Constants
const PERFECT_WINDOW = 0.05
const GOOD_WINDOW = 0.1
const MISS_WINDOW = 0.15
const KICK_COLOR = Color(1, 0.2, 0.2)  # Red
const SNARE_COLOR = Color(0.2, 1, 0.2)  # Green
const HIHAT_COLOR = Color(0.2, 0.2, 1)  # Blue
const INACTIVE_COLOR = Color(0.3, 0.3, 0.3)  # Gray

# Visual settings
@export var wheel_radius: float = 200.0
@export var beat_circle_radius: float = 30.0
@export var wheel_center_offset: Vector2 = Vector2(-270, 10)  # Offset of the drum wheel sprite

# Audio settings
@export var bpm: float = 120.0

# Pattern data - predetermined patterns for each drum type
# Beats 1 & 5 (indices 0 & 4)
var kick_pattern = [true, false, false, false, true, false, false, false]
# Beats 3 & 7 (indices 2 & 6)
var snare_pattern = [false, false, true, false, false, false, true, false]
# Beats 2, 4, 6, 8 (indices 1, 3, 5, 7)
var hihat_pattern = [false, true, false, true, false, true, false, true]

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


func _ready():
	# Calculate rotation speed based on BPM
	var beat_duration = 60.0 / bpm
	base_rotation_speed = TAU / (beat_duration * 8)  # 8 beats per rotation
	rotation_speed = base_rotation_speed

	# Setup hit targets
	setup_hit_targets()

	# Setup arrow with proper offset
	if arrow_node:
		# Set the arrow's offset so it rotates from its bottom
		# This makes it rotate like a clock hand
		arrow_node.offset = Vector2(0, -100)  # Adjust based on arrow sprite size

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




func get_color_for_layer(layer: DrumType) -> Color:
	match layer:
		DrumType.KICK:
			return KICK_COLOR
		DrumType.SNARE:
			return SNARE_COLOR
		DrumType.HIHAT:
			return HIHAT_COLOR
	return Color.WHITE




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
	update_target_visuals()


func start_next_level():
	# For now, just reset the game
	# In the future, this could load a new pattern or increase difficulty
	reset_game()

	# Let HUD know level has started
	emit_signal("level_started")


func show_hit_feedback_at_beat(beat_number: int, timing_quality: String):
	# Find if there's a hit target at this beat
	for i in range(hit_targets.size()):
		var target = hit_targets[i]
		if target.has_meta("beat_number") and target.get_meta("beat_number") == beat_number:
			if timing_quality == "PERFECT" or timing_quality == "GOOD":
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
