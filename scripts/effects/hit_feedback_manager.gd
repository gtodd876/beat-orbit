class_name HitFeedbackManager
extends Node2D

# Preloaded scene
const HIT_FEEDBACK_SCENE = preload("res://scenes/effects/hit_feedback_text.tscn")

# Colors for feedback
const PERFECT_COLOR = Color(1.0, 0.9, 0.2)  # Golden yellow
const GOOD_COLOR = Color(0.2, 0.8, 1.0)  # Blue from palette
const MISS_COLOR = Color(0.85, 0.35, 0.85)  # Magenta (HSL 303, 67, 51)


func spawn_feedback(pos: Vector2, timing_quality: String):
	var feedback = HIT_FEEDBACK_SCENE.instantiate()

	# Add child first
	add_child(feedback)

	# Then set global position to ensure proper placement
	feedback.global_position = pos

	# Set high z_index to appear above pattern grid
	feedback.z_index = 100

	# The scene root is a Label, so we can set text directly
	if feedback is Label:
		feedback.text = timing_quality

	# Set color based on timing
	match timing_quality:
		"PERFECT":
			feedback.modulate = PERFECT_COLOR
		"GOOD":
			feedback.modulate = GOOD_COLOR
		"MISS":
			feedback.modulate = MISS_COLOR

	# Create animation sequence
	var tween = create_tween()
	tween.bind_node(feedback)  # Bind to prevent errors if freed
	tween.set_parallel(true)

	# Start state
	feedback.scale = Vector2(0.5, 0.5)
	feedback.modulate.a = 1.0

	# Animation sequence
	# Quick scale up
	(
		tween
		. tween_property(feedback, "scale", Vector2(1.2, 1.2), 0.15)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_BACK)
	)
	# Move up while fading - use global position
	(
		tween
		. tween_property(feedback, "global_position:y", pos.y - 50, 0.8)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	# Fade out
	tween.tween_property(feedback, "modulate:a", 0.0, 0.6).set_delay(0.2).set_ease(Tween.EASE_IN)

	# Scale down slightly while fading
	tween.chain().tween_property(feedback, "scale", Vector2(0.8, 0.8), 0.4).set_ease(
		Tween.EASE_IN_OUT
	)

	# Remove after animation
	tween.finished.connect(func(): feedback.queue_free())
