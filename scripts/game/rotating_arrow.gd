class_name RotatingArrow
extends Node2D

# Visual properties
@export var arrow_length: float = 200.0
@export var arrow_width: float = 8.0
@export var arrow_head_size: float = 20.0
@export var arrow_color: Color = Color(0, 1, 1)  # Cyan
@export var glow_intensity: float = 0.8

# Rotation state
var current_rotation: float = 0.0


func _ready():
	set_process(true)


func _process(_delta):
	queue_redraw()


func _draw():
	# Draw arrow stem from center to edge
	var stem_end = Vector2(arrow_length - arrow_head_size, 0)
	draw_line(Vector2.ZERO, stem_end, arrow_color, arrow_width)
	
	# Draw arrow head
	var arrow_tip = Vector2(arrow_length, 0)
	var arrow_left = Vector2(arrow_length - arrow_head_size, -arrow_head_size / 2)
	var arrow_right = Vector2(arrow_length - arrow_head_size, arrow_head_size / 2)
	
	var arrow_points = PackedVector2Array([
		arrow_left,
		arrow_tip,
		arrow_right
	])
	
	draw_colored_polygon(arrow_points, arrow_color)
	
	# Draw glow effect
	if glow_intensity > 0:
		# Stem glow
		for i in range(3):
			var glow_width = arrow_width + (i + 1) * 4
			var glow_color = arrow_color
			glow_color.a = glow_intensity * (0.3 / (i + 1))
			draw_line(Vector2.ZERO, stem_end, glow_color, glow_width)
		
		# Arrow head glow
		for i in range(3):
			var scale_factor = 1.0 + (i + 1) * 0.2
			var glow_points = PackedVector2Array()
			for point in arrow_points:
				var scaled_point = point - Vector2(arrow_length - arrow_head_size / 2, 0)
				scaled_point *= scale_factor
				scaled_point += Vector2(arrow_length - arrow_head_size / 2, 0)
				glow_points.append(scaled_point)
			
			var glow_color = arrow_color
			glow_color.a = glow_intensity * (0.3 / (i + 1))
			draw_colored_polygon(glow_points, glow_color)
	
	# Draw center pivot point
	draw_circle(Vector2.ZERO, 10, arrow_color)
	draw_circle(Vector2.ZERO, 8, Color(0.1, 0.1, 0.2))  # Dark center