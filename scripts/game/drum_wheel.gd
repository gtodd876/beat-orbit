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

# Timing windows (in seconds)
const PERFECT_WINDOW = 0.05
const GOOD_WINDOW = 0.1
const MISS_WINDOW = 0.15

# Visual settings
@export var wheel_radius: float = 200.0
@export var beat_circle_radius: float = 30.0

# Audio settings
@export var bpm: float = 120.0

# Pattern data - predetermined patterns for each drum type
var kick_pattern = [true, false, false, false, true, false, false, false]  # Beats 1 & 5
var snare_pattern = [false, false, true, false, false, false, true, false]  # Beats 3 & 7
var hihat_pattern = [false, true, false, true, false, true, false, true]  # Beats 2, 4, 6, 8

# Game state
var current_layer: DrumType = DrumType.KICK
var completed_layers: Dictionary = {
	DrumType.KICK: false,
	DrumType.SNARE: false,
	DrumType.HIHAT: false
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

# Visual elements
var beat_circles: Array = []
var rotating_arrow: Node2D

# Colors
var kick_color = Color(1, 0.2, 0.2)  # Red
var snare_color = Color(0.2, 1, 0.2)  # Green
var hihat_color = Color(0.2, 0.2, 1)  # Blue
var inactive_color = Color(0.3, 0.3, 0.3)  # Gray


func _ready():
	# Calculate rotation speed based on BPM
	var beat_duration = 60.0 / bpm
	base_rotation_speed = TAU / (beat_duration * 8)  # 8 beats per rotation
	rotation_speed = base_rotation_speed

	# Create beat circles
	create_beat_circles()

	# Create rotating arrow
	create_rotating_arrow()

	# Start playing
	is_playing = true
	update_beat_visuals()


func create_beat_circles():
	for i in range(8):
		var angle = (i * TAU / 8) - PI / 2  # Start at top (12 o'clock)
		var circle = Node2D.new()
		circle.position = Vector2(wheel_radius, 0).rotated(angle)
		circle.set_meta("beat_number", i)
		circle.set_script(load("res://scripts/game/beat_circle.gd"))
		add_child(circle)
		beat_circles.append(circle)


func create_rotating_arrow():
	rotating_arrow = Node2D.new()
	rotating_arrow.set_script(load("res://scripts/game/rotating_arrow.gd"))
	add_child(rotating_arrow)


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
	if rotating_arrow:
		rotating_arrow.rotation = arrow_rotation

	# Update beat timer
	beat_timer += delta
	# Beat duration would be 60.0 / bpm, but not needed here

	# Check if we've hit a new beat
	var new_beat = int((arrow_rotation + PI/2) / (TAU / 8)) % 8
	if new_beat != current_beat:
		current_beat = new_beat
		emit_signal("beat_played", current_beat)
		play_pattern_sounds()


func _input(event):
	if event.is_action_pressed("hit_drum"):
		if is_pattern_complete:
			# When pattern is complete, SPACE advances to next level
			start_next_level()
		elif not is_animating:
			check_hit()


func check_hit():
	# Calculate which beat the arrow is closest to
	var normalized_angle = wrapf(arrow_rotation + PI/2, 0, TAU)
	var beat_angle = TAU / 8
	var closest_beat = int(round(normalized_angle / beat_angle)) % 8

	# Calculate timing accuracy
	var beat_target_angle = (closest_beat * beat_angle) - PI/2
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

		# Visual feedback on beat circle
		if closest_beat < beat_circles.size():
			beat_circles[closest_beat].show_hit_feedback(get_layer_color(), timing_quality)

		# Start wild animation
		start_wild_animation(current_layer)

		# Check if layer is complete
		if is_layer_complete(current_layer):
			complete_current_layer()

		# Play drum sound
		play_drum_sound(current_layer)
	else:
		# Show miss feedback
		if closest_beat < beat_circles.size():
			beat_circles[closest_beat].show_hit_feedback(Color.RED, "MISS")

		# Play miss sound
		play_miss_sound()

	emit_signal("drum_hit", current_layer, timing_quality, closest_beat)


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
	var normalized_angle = wrapf(arrow_rotation + PI/2, 0, TAU)
	var nearest_beat = round(normalized_angle / beat_angle)
	var target_angle = (nearest_beat * beat_angle) - PI/2

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
		update_beat_visuals()
	elif current_layer == DrumType.SNARE:
		current_layer = DrumType.HIHAT
		update_beat_visuals()
	elif current_layer == DrumType.HIHAT:
		# All layers complete!
		is_pattern_complete = true
		emit_signal("pattern_complete")
		# Hide all beat circles since pattern is complete
		for circle in beat_circles:
			circle.set_target_beat(false, inactive_color)


func update_beat_visuals():
	var pattern = get_pattern_for_layer(current_layer)
	var color = get_layer_color()

	for i in range(beat_circles.size()):
		if pattern[i]:
			beat_circles[i].set_target_beat(true, color)
		else:
			beat_circles[i].set_target_beat(false, inactive_color)

		# Show completed beats from previous layers
		for layer in completed_layers:
			if completed_layers[layer]:
				var layer_pattern = get_pattern_for_layer(layer)
				if layer_pattern[i] and player_pattern[layer][i]:
					beat_circles[i].add_completed_layer(layer, get_color_for_layer(layer))


func get_layer_color() -> Color:
	return get_color_for_layer(current_layer)


func get_color_for_layer(layer: DrumType) -> Color:
	match layer:
		DrumType.KICK:
			return kick_color
		DrumType.SNARE:
			return snare_color
		DrumType.HIHAT:
			return hihat_color
	return Color.WHITE


func play_pattern_sounds():
	# Play all sounds that have been successfully placed (not just completed layers)
	for layer in player_pattern:
		var pattern = get_pattern_for_layer(layer)
		if pattern[current_beat] and player_pattern[layer][current_beat]:
			play_drum_sound(layer)


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
	arrow_rotation = -PI/2  # Start at top
	is_animating = false
	is_pattern_complete = false
	update_beat_visuals()


func start_next_level():
	# For now, just reset the game
	# In the future, this could load a new pattern or increase difficulty
	reset_game()
	
	# Let HUD know level has started
	emit_signal("level_started")
