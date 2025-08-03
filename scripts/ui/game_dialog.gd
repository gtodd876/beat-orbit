extends Control

signal continue_pressed

enum DialogType { LEVEL_COMPLETE, GAME_OVER, GAME_WIN }

var current_score: int = 0
var combo_bonus: int = 0
var final_score: int = 0
var dialog_type: DialogType
var can_continue: bool = false
var continue_delay_timer: float = 0.0

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready
var score_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ScoreContainer/ScoreLabel
@onready
var combo_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ComboContainer/ComboLabel
@onready
var total_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TotalContainer/TotalLabel
@onready var action_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ActionLabel


func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Ensure dialog is on top
	z_index = 100
	set_process(true)



func _process(delta):
	if (
		visible
		and (dialog_type == DialogType.LEVEL_COMPLETE or dialog_type == DialogType.GAME_WIN)
		and not can_continue
	):
		continue_delay_timer += delta
		if continue_delay_timer >= 4.0:
			can_continue = true
			if dialog_type == DialogType.LEVEL_COMPLETE:
				action_label.text = "Press SPACE for next level"
			else:  # GAME_WIN
				action_label.text = "You Win! Press SPACE to restart"
			# Animate the action label appearing
			action_label.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(action_label, "modulate:a", 1.0, 0.5)


func show_dialog(type: DialogType, score: int, combo: int):
	dialog_type = type
	current_score = score
	combo_bonus = combo * 100
	final_score = current_score + combo_bonus
	can_continue = false
	continue_delay_timer = 0.0

	# print("Dialog show_dialog called with type: ", type)
	visible = true
	# print("Dialog visible set to true")

	# Ensure all labels exist
	if not title_label:
		# print("ERROR: title_label is null!")
		return

	# Set initial state for animation (slide in from left)
	modulate.a = 0.0
	position.x = -100

	# Animate dialog entrance
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:x", 0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)

	match type:
		DialogType.LEVEL_COMPLETE:
			title_label.text = "Level Complete!"
			action_label.text = ""  # Start empty, will show after delay
		DialogType.GAME_OVER:
			title_label.text = "Game Over"
			action_label.text = "Press SPACE to restart"
		DialogType.GAME_WIN:
			title_label.text = "Congratulations!"
			action_label.text = ""  # Start empty, will show after delay

	score_label.text = "Score: %d" % current_score
	combo_label.text = "Combo Bonus: 0"
	total_label.text = "Total: %d" % current_score

	animate_score_rollup()


func animate_score_rollup():
	var tween = create_tween()

	(
		tween
		. tween_method(update_combo_display, 0, combo_bonus, 1.0)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)

	tween.finished.connect(
		func():
			total_label.modulate = Color(0, 1, 1)
			var flash_tween = create_tween()
			flash_tween.tween_property(total_label, "modulate", Color.WHITE, 0.5)
	)


func update_combo_display(value: int):
	combo_label.text = "Combo Bonus: %d" % value
	total_label.text = "Total: %d" % (current_score + value)


func _input(event):
	if visible and event.is_action_pressed("hit_drum"):
		# Check if we can continue (for level complete and game win, need to wait)
		if (
			(dialog_type == DialogType.LEVEL_COMPLETE or dialog_type == DialogType.GAME_WIN)
			and not can_continue
		):
			return  # Ignore input during delay

		hide_dialog()
		# Consume the event so it doesn't trigger a drum hit
		get_viewport().set_input_as_handled()


func hide_dialog():
	# Animate dialog exit (slide out to left)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:x", -100, 0.2).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_IN
	)
	tween.finished.connect(
		func():
			visible = false
			emit_signal("continue_pressed")
	)
