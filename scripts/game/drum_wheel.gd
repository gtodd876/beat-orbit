class_name DrumWheel
extends Node2D
# Signals
signal drum_hit(drum_type: DrumType, timing_quality: String, beat_position: int)
signal pattern_complete
signal beat_played(position: int)

# Drum types
enum DrumType { KICK, SNARE, HIHAT }

# Timing windows (in radians)
const PERFECT_WINDOW = 0.15
const GOOD_WINDOW = 0.3
const MISS_WINDOW = 0.5

# Visual settings
@export var wheel_radius: float = 200.0
@export var rotation_speed: float = 1.0  # radians per second
@export var arrow_count: int = 8
@export var hit_zone_angle: float = 0.0  # Top of wheel

# Audio settings
@export var bpm: float = 120.0
@export var measures: int = 2
@export var beats_per_measure: int = 4

# Arrow scene (to be created)
@export var arrow_scene: PackedScene

# Hit feedback colors
var perfect_color = Color(0, 1, 1)  # Cyan
var good_color = Color(1, 1, 0)  # Yellow
var miss_color = Color(1, 0, 0)  # Red

# Game state
var arrows: Array = []
var current_pattern: Array = []  # Stores the recorded drum pattern
var pattern_position: int = 0
var beat_timer: float = 0.0
var is_playing: bool = false


func _ready():
	# Calculate beat duration
	var beat_duration = 60.0 / bpm
	var total_beats = measures * beats_per_measure

	# Calculate rotation speed to sync with BPM
	# One full rotation should take the same time as the full pattern
	var pattern_duration = beat_duration * total_beats
	rotation_speed = TAU / pattern_duration

	# Initialize pattern array
	current_pattern.resize(total_beats)
	for i in total_beats:
		current_pattern[i] = []

	# Create arrows
	spawn_arrows()

	# Start the wheel spinning
	is_playing = true


func spawn_arrows():
	if not arrow_scene:
		push_error("Arrow scene not set!")
		return

	var angle_step = TAU / arrow_count

	for i in arrow_count:
		var arrow = arrow_scene.instantiate()
		var angle = i * angle_step
		var drum_type = i % 3  # Cycle through KICK, SNARE, HIHAT

		arrow.position = Vector2(wheel_radius, 0).rotated(angle)
		arrow.rotation = angle + PI / 2  # Point outward
		arrow.drum_type = drum_type
		arrow.set_meta("angle", angle)

		add_child(arrow)
		arrows.append(arrow)


func _process(delta):
	if not is_playing:
		return

	# Rotate all arrows
	for arrow in arrows:
		var current_angle = arrow.get_meta("angle")
		current_angle += rotation_speed * delta

		# Wrap around
		if current_angle > TAU:
			current_angle -= TAU

		arrow.set_meta("angle", current_angle)
		arrow.position = Vector2(wheel_radius, 0).rotated(current_angle)
		arrow.rotation = current_angle + PI / 2

	# Update beat timer
	beat_timer += delta
	var beat_duration = 60.0 / bpm

	if beat_timer >= beat_duration:
		beat_timer -= beat_duration
		play_current_beat()
		pattern_position = (pattern_position + 1) % current_pattern.size()

		if pattern_position == 0:
			emit_signal("pattern_complete")


func _input(event):
	if event.is_action_pressed("hit_drum"):
		check_hit()


func check_hit():
	var closest_arrow = null
	var closest_distance = INF

	# Find the arrow closest to the hit zone
	for arrow in arrows:
		var angle = arrow.get_meta("angle")
		var distance = abs(angle_difference(angle, hit_zone_angle))

		if distance < closest_distance:
			closest_distance = distance
			closest_arrow = arrow

	if not closest_arrow:
		return

	# Determine timing quality
	var timing_quality = ""
	if closest_distance <= PERFECT_WINDOW:
		timing_quality = "PERFECT"
		show_hit_feedback(perfect_color)
		add_to_pattern(closest_arrow.drum_type)
	elif closest_distance <= GOOD_WINDOW:
		timing_quality = "GOOD"
		show_hit_feedback(good_color)
		add_to_pattern(closest_arrow.drum_type)
	else:
		timing_quality = "MISS"
		show_hit_feedback(miss_color)

	emit_signal("drum_hit", closest_arrow.drum_type, timing_quality, pattern_position)


func angle_difference(angle1: float, angle2: float) -> float:
	var diff = angle1 - angle2

	# Normalize to [-PI, PI]
	while diff > PI:
		diff -= TAU
	while diff < -PI:
		diff += TAU

	return diff


func add_to_pattern(drum_type: DrumType):
	# Add this drum hit to the current beat in the pattern
	if not drum_type in current_pattern[pattern_position]:
		current_pattern[pattern_position].append(drum_type)


func play_current_beat():
	# Play all drums scheduled for this beat
	var drums_to_play = current_pattern[pattern_position]

	for drum_type in drums_to_play:
		play_drum_sound(drum_type)

	emit_signal("beat_played", pattern_position)


func play_drum_sound(drum_type: DrumType):
	# This will be connected to actual audio players
	match drum_type:
		DrumType.KICK:
			print("KICK!")
		DrumType.SNARE:
			print("SNARE!")
		DrumType.HIHAT:
			print("HAT!")


func show_hit_feedback(color: Color):
	# Visual feedback for hits - we'll implement this with particles/effects
	modulate = color
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.2)


func clear_pattern():
	for i in current_pattern.size():
		current_pattern[i].clear()


func get_pattern_as_string() -> String:
	# Useful for debugging and saving patterns
	var pattern_str = ""
	for beat in current_pattern:
		if beat.is_empty():
			pattern_str += "."
		else:
			for drum in beat:
				match drum:
					DrumType.KICK:
						pattern_str += "K"
					DrumType.SNARE:
						pattern_str += "S"
					DrumType.HIHAT:
						pattern_str += "H"
		pattern_str += " "
	return pattern_str
