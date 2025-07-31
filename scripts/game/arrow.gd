class_name Arrow
extends Node2D

# Visual properties
@export var arrow_color: Color = Color(1, 1, 1)
@export var glow_intensity: float = 1.0

# Drum type this arrow represents
var drum_type: DrumWheel.DrumType = DrumWheel.DrumType.KICK

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var glow_sprite: Sprite2D = $GlowSprite


func _ready():
	# Set color based on drum type
	match drum_type:
		DrumWheel.DrumType.KICK:
			arrow_color = Color(1, 0.2, 0.2)  # Red
		DrumWheel.DrumType.SNARE:
			arrow_color = Color(0.2, 1, 0.2)  # Green
		DrumWheel.DrumType.HIHAT:
			arrow_color = Color(0.2, 0.2, 1)  # Blue

	update_visuals()


func update_visuals():
	if sprite:
		sprite.modulate = arrow_color
	if glow_sprite:
		glow_sprite.modulate = arrow_color
		glow_sprite.modulate.a = glow_intensity


func pulse():
	# Visual feedback when in hit zone
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
