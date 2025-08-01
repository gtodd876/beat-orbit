extends VBoxContainer

# Visual settings
@export var empty_text: String = "_"
@export var hit_text: String = "X"
@export var cell_size: Vector2 = Vector2(30, 20)

# Colors for different drum types
@export var kick_color: Color = Color(1, 0.3, 0.3)  # Red
@export var snare_color: Color = Color(0.3, 1, 0.3)  # Green
@export var hihat_color: Color = Color(0.5, 0.5, 1)  # Blue
@export var empty_color: Color = Color(0.5, 0.5, 0.5)  # Gray

# Beat cursor
var cursor_position: int = 0
var cursor_labels: Array = []

# Grid references
@onready var header_row = $HeaderRow
@onready var grid_container = $GridContainer


func _ready():
	setup_grid()


func setup_grid():
	# Clear existing children
	for child in header_row.get_children():
		if child.name != "Spacer":
			child.queue_free()

	for child in grid_container.get_children():
		child.queue_free()

	# Create header numbers
	for i in range(8):
		var num_label = Label.new()
		num_label.text = str(i + 1)
		num_label.custom_minimum_size = cell_size
		num_label.add_theme_font_size_override("font_size", 16)
		num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header_row.add_child(num_label)

	# Create grid cells
	# Row labels
	var drums = ["K:", "S:", "H:"]
	var drum_colors = [kick_color, snare_color, hihat_color]

	for row in range(3):
		# Add row label
		var row_label = Label.new()
		row_label.text = drums[row]
		row_label.custom_minimum_size = Vector2(30, 20)
		row_label.modulate = drum_colors[row]
		row_label.add_theme_font_size_override("font_size", 16)
		grid_container.add_child(row_label)

		# Add cells for each beat
		for col in range(8):
			var cell = Label.new()
			cell.text = empty_text
			cell.custom_minimum_size = cell_size
			cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			cell.modulate = empty_color
			cell.add_theme_font_size_override("font_size", 16)
			cell.name = "Cell_%d_%d" % [row, col]
			grid_container.add_child(cell)

	# Create cursor row
	var cursor_spacer = Label.new()
	cursor_spacer.custom_minimum_size = Vector2(30, 20)
	grid_container.add_child(cursor_spacer)

	cursor_labels.clear()
	for col in range(8):
		var cursor_label = Label.new()
		cursor_label.text = ""
		cursor_label.custom_minimum_size = cell_size
		cursor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cursor_label.modulate = Color(0, 1, 1)  # Cyan
		cursor_label.add_theme_font_size_override("font_size", 16)
		grid_container.add_child(cursor_label)
		cursor_labels.append(cursor_label)


func update_pattern(pattern: Array):
	for beat_idx in range(pattern.size()):
		var has_kick = false
		var has_snare = false
		var has_hihat = false

		for drum_type in pattern[beat_idx]:
			match drum_type:
				0:  # KICK
					has_kick = true
				1:  # SNARE
					has_snare = true
				2:  # HIHAT
					has_hihat = true

		# Update kick cell
		var kick_cell = grid_container.get_node_or_null("Cell_0_%d" % beat_idx)
		if kick_cell:
			kick_cell.text = hit_text if has_kick else empty_text
			kick_cell.modulate = kick_color if has_kick else empty_color

		# Update snare cell
		var snare_cell = grid_container.get_node_or_null("Cell_1_%d" % beat_idx)
		if snare_cell:
			snare_cell.text = hit_text if has_snare else empty_text
			snare_cell.modulate = snare_color if has_snare else empty_color

		# Update hihat cell
		var hihat_cell = grid_container.get_node_or_null("Cell_2_%d" % beat_idx)
		if hihat_cell:
			hihat_cell.text = hit_text if has_hihat else empty_text
			hihat_cell.modulate = hihat_color if has_hihat else empty_color


func update_cursor(beat_position: int):
	cursor_position = beat_position

	# Clear all cursor labels
	for i in range(cursor_labels.size()):
		cursor_labels[i].text = ""

	# Set cursor at current position
	if beat_position >= 0 and beat_position < cursor_labels.size():
		cursor_labels[beat_position].text = "*"