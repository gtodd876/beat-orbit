class_name UISoundManager
extends Node

# UI sound types
enum UISound {
	BUTTON_HOVER,
	BUTTON_CLICK,
	DIALOG_OPEN,
	DIALOG_CLOSE,
	COMBO_MILESTONE,
	LAYER_COMPLETE,
	PATTERN_COMPLETE,
	PAUSE_IN,
	PAUSE_OUT
}

# Constants
const MISS_SOUND = preload("res://assets/audio/sfx/miss.wav")

# Audio stream players
var audio_players: Dictionary = {}


func _ready():
	# Create audio players for each UI sound
	for sound in UISound.values():
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"  # Use SFX bus
		add_child(player)
		audio_players[sound] = player

	# Load available sounds (for now we'll use what we have)
	# In a full implementation, you'd load specific UI sounds here


func play_sound(sound_type: UISound, volume_db: float = 0.0):
	"""Play a UI sound effect"""
	if sound_type in audio_players:
		var player = audio_players[sound_type]
		player.volume_db = volume_db

		# For now, use the miss sound as a placeholder click sound
		# In production, you'd have specific sounds for each type
		match sound_type:
			UISound.BUTTON_HOVER:
				# Placeholder: Use a quieter version of miss sound
				player.stream = MISS_SOUND
				player.volume_db = -20.0
				player.pitch_scale = 1.5
			UISound.BUTTON_CLICK, UISound.DIALOG_OPEN, UISound.PAUSE_IN:
				# Placeholder: Use miss sound at different pitch
				player.stream = MISS_SOUND
				player.volume_db = -12.0
				player.pitch_scale = 1.2
			UISound.DIALOG_CLOSE, UISound.PAUSE_OUT:
				# Placeholder: Use miss sound at lower pitch
				player.stream = MISS_SOUND
				player.volume_db = -12.0
				player.pitch_scale = 0.8
			UISound.COMBO_MILESTONE:
				# Placeholder: Use miss sound with higher pitch for celebration
				player.stream = MISS_SOUND
				player.volume_db = -10.0
				player.pitch_scale = 2.0
			UISound.LAYER_COMPLETE:
				# Placeholder: Use miss sound sequence
				player.stream = MISS_SOUND
				player.volume_db = -8.0
				player.pitch_scale = 1.5
			UISound.PATTERN_COMPLETE:
				# Placeholder: Use miss sound with echo effect
				player.stream = MISS_SOUND
				player.volume_db = -6.0
				player.pitch_scale = 1.0

		if player.stream:
			player.play()


func play_combo_milestone():
	"""Special function for combo milestone with ascending notes"""
	play_sound(UISound.COMBO_MILESTONE)


func play_layer_complete():
	"""Play layer completion sound"""
	play_sound(UISound.LAYER_COMPLETE)


func play_pattern_complete():
	"""Play pattern completion sound"""
	play_sound(UISound.PATTERN_COMPLETE)
