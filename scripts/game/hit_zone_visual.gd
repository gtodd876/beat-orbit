extends Node2D

@export var arc_radius: float = 200.0
@export var arc_width: float = 40.0
@export var arc_angle: float = 45.0  # degrees
@export var arc_color: Color = Color(0, 1, 1, 0.5)  # Cyan with transparency
@export var pulse_speed: float = 2.0
@export var pulse_intensity: float = 0.3

var time: float = 0.0

func _ready():
	set_process(true)

func _process(delta):
	time += delta
	queue_redraw()

func _draw():
	# Calculate pulse effect
	var pulse = 1.0 + sin(time * pulse_speed * TAU) * pulse_intensity
	var current_color = arc_color
	current_color.a = arc_color.a * pulse

	# Draw the hit zone arc
	var start_angle = -90 - (arc_angle / 2)  # Center at top
	var end_angle = -90 + (arc_angle / 2)

	# Draw outer glow arc
	var glow_color = current_color
	glow_color.a *= 0.3
	draw_arc(
		Vector2.ZERO,
		arc_radius,
		deg_to_rad(start_angle),
		deg_to_rad(end_angle),
		32,  # Number of points
		glow_color,
		arc_width * 1.5,
		true  # Antialiased
	)

	# Draw main arc
	draw_arc(
		Vector2.ZERO,
		arc_radius,
		deg_to_rad(start_angle),
		deg_to_rad(end_angle),
		32,  # Number of points
		current_color,
		arc_width,
		true  # Antialiased
	)

	# Draw inner bright line
	var bright_color = current_color
	bright_color.a = min(1.0, current_color.a * 1.5)
	draw_arc(
		Vector2.ZERO,
		arc_radius,
		deg_to_rad(start_angle),
		deg_to_rad(end_angle),
		32,  # Number of points
		bright_color,
		2.0,
		true  # Antialiased
	)

	# Draw edge markers
	var start_point_inner = Vector2(0, -(arc_radius - arc_width/2)).rotated(deg_to_rad(start_angle))
	var start_point_outer = Vector2(0, -(arc_radius + arc_width/2)).rotated(deg_to_rad(start_angle))
	var end_point_inner = Vector2(0, -(arc_radius - arc_width/2)).rotated(deg_to_rad(end_angle))
	var end_point_outer = Vector2(0, -(arc_radius + arc_width/2)).rotated(deg_to_rad(end_angle))

	draw_line(start_point_inner, start_point_outer, bright_color, 4.0, true)
	draw_line(end_point_inner, end_point_outer, bright_color, 4.0, true)

	# Draw "HIT ZONE" text
	var font = ThemeDB.fallback_font
	var text = "HIT ZONE"
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	var text_pos = Vector2(0, -arc_radius - arc_width - 20)
	draw_string(
		font,
		text_pos - Vector2(text_size.x/2, 0),
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		16,
		bright_color
	)