class_name ScreenShakeManager
extends Camera2D

# Shake parameters
var shake_intensity: float = 0.0
var shake_decay: float = 5.0  # How fast the shake fades
var max_offset: Vector2 = Vector2(10, 10)  # Maximum shake offset

# Internal state
var _shake_timer: float = 0.0
var _initial_position: Vector2


func _ready():
	# Store the initial position
	_initial_position = position
	# Make this the current camera
	make_current()


func _process(delta):
	if _shake_timer > 0:
		_shake_timer -= delta * shake_decay
		_shake_timer = max(0, _shake_timer)

		# Calculate shake offset
		var offset = (
			Vector2(
				randf_range(-max_offset.x, max_offset.x), randf_range(-max_offset.y, max_offset.y)
			)
			* _shake_timer
		)

		# Apply shake
		position = _initial_position + offset
	else:
		# Return to initial position
		position = _initial_position


func shake(intensity: float = 1.0, duration: float = 0.2):
	"""Trigger a screen shake effect"""
	shake_intensity = clamp(intensity, 0.0, 1.0)
	_shake_timer = duration


func shake_perfect_hit():
	"""Subtle shake for perfect hits"""
	shake(0.3, 0.15)


func shake_layer_complete():
	"""Medium shake for layer completion"""
	shake(0.6, 0.3)


func shake_pattern_complete():
	"""Strong shake for pattern completion"""
	shake(1.0, 0.5)
