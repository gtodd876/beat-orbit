extends Control

signal resume_pressed

var is_paused: bool = false
@onready var ui_sound_manager = null


func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Try to find UI sound manager
	ui_sound_manager = get_node_or_null("/root/Game/UISoundManager")


func show_pause():
	is_paused = true
	visible = true
	get_tree().paused = true

	# Animate pause menu entrance
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	# Play pause sound
	# TEMP: Disabled until proper UI sounds are implemented
	# if ui_sound_manager:
	# 	ui_sound_manager.play_sound(ui_sound_manager.UISound.PAUSE_IN)

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continue during pause
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	(
		tween
		. tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)


func hide_pause():
	is_paused = false

	# Animate pause menu exit
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continue during pause
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	(
		tween
		. tween_property(self, "scale", Vector2(0.9, 0.9), 0.2)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_IN)
	)
	tween.finished.connect(
		func():
			visible = false
			get_tree().paused = false
			# Play unpause sound
			# TEMP: Disabled until proper UI sounds are implemented
			# if ui_sound_manager:
			# 	ui_sound_manager.play_sound(ui_sound_manager.UISound.PAUSE_OUT)
	)


func _input(event):
	if event.is_action_pressed("pause"):
		if is_paused:
			hide_pause()
			emit_signal("resume_pressed")
		else:
			show_pause()
