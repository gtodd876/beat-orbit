extends Node2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready():
	print("Project setup complete!")
	print("Display size: ", get_viewport().size)
	print("Audio latency: ", AudioServer.get_output_latency())

	# Important for web games - wait for user interaction
	if OS.has_feature("web"):
		print("Running in web browser")


func _input(event):
	if event.is_action_pressed("hit_drum"):
		print("Drum hit!")
		# This will also trigger audio permission in browsers
		audio_stream_player_2d.play()
