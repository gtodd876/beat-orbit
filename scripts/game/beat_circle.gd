class_name BeatCircle
extends Node2D

# Visual properties
@export var circle_radius: float = 30.0
@export var outline_width: float = 3.0

# State
var is_target_beat: bool = false
var target_color: Color = Color(0.3, 0.3, 0.3)
var completed_layers: Dictionary = {}
var pulse_timer: float = 0.0
var hit_feedback_timer: float = 0.0
var hit_feedback_color: Color = Color.WHITE
var hit_feedback_active: bool = false

# Beat number (0-7)
var beat_number: int = 0


func _ready():
	beat_number = get_meta("beat_number", 0)
	set_process(true)


func _process(delta):
	# Pulse effect for target beats
	if is_target_beat:
		pulse_timer += delta * 2.0
		queue_redraw()
	
	# Hit feedback animation
	if hit_feedback_active:
		hit_feedback_timer -= delta
		if hit_feedback_timer <= 0:
			hit_feedback_active = false
		queue_redraw()


func _draw():
	var base_radius = circle_radius
	
	# Draw completed layer indicators
	if not completed_layers.is_empty():
		var layer_count = completed_layers.size()
		var ring_width = 8.0
		var ring_spacing = 2.0
		
		var i = 0
		for layer in completed_layers:
			var layer_radius = base_radius + (i * (ring_width + ring_spacing)) + 5
			var layer_color = completed_layers[layer]
			layer_color.a = 0.8
			draw_arc(Vector2.ZERO, layer_radius, 0, TAU, 64, layer_color, ring_width)
			i += 1
	
	# Draw main circle
	var fill_color = target_color
	if is_target_beat and pulse_timer > 0:
		# Pulse effect
		var pulse = sin(pulse_timer) * 0.5 + 0.5
		fill_color.a = 0.3 + pulse * 0.4
		base_radius = circle_radius + pulse * 5
	else:
		fill_color.a = 0.3
	
	# Fill
	draw_circle(Vector2.ZERO, base_radius, fill_color)
	
	# Outline
	draw_arc(Vector2.ZERO, base_radius, 0, TAU, 64, target_color, outline_width)
	
	# Beat number
	var font = ThemeDB.fallback_font
	var font_size = 16
	var text = str(beat_number + 1)
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos = Vector2(-text_size.x / 2, text_size.y / 4)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
	
	# Hit feedback
	if hit_feedback_active:
		var feedback_alpha = hit_feedback_timer / 0.5
		var feedback_scale = 1.0 + (1.0 - feedback_alpha) * 0.5
		var feedback_color = hit_feedback_color
		feedback_color.a = feedback_alpha * 0.6
		draw_circle(Vector2.ZERO, base_radius * feedback_scale, feedback_color)


func set_target_beat(is_target: bool, color: Color):
	is_target_beat = is_target
	target_color = color
	pulse_timer = 0.0
	queue_redraw()


func show_hit_feedback(color: Color, quality: String):
	hit_feedback_active = true
	hit_feedback_timer = 0.5
	hit_feedback_color = color
	
	# Create expanding ring effect
	var ring = Node2D.new()
	add_child(ring)
	ring.modulate = color
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.0, 2.0), 0.4)
	tween.tween_property(ring, "modulate:a", 0.0, 0.4)
	tween.finished.connect(func(): ring.queue_free())
	
	# Add quality text
	if quality != "MISS":
		var label = Label.new()
		label.text = quality
		label.add_theme_font_size_override("font_size", 24)
		label.modulate = color
		label.position = Vector2(-50, -50)
		add_child(label)
		
		var text_tween = create_tween()
		text_tween.set_parallel(true)
		text_tween.tween_property(label, "position:y", -80, 0.6)
		text_tween.tween_property(label, "modulate:a", 0.0, 0.6)
		text_tween.finished.connect(func(): label.queue_free())


func add_completed_layer(layer: DrumWheel.DrumType, color: Color):
	completed_layers[layer] = color
	queue_redraw()