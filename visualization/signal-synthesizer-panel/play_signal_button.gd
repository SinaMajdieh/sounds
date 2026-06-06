extends PlaybackButton

@export_subgroup("Audio")
@export var frequency_tuner: FrequencyDataTuner

var oscillator: CosGenerator

func _ready() -> void:
	super()
	frequency_tuner.frequency_data_changed.connect(_on_frequency_data_changed)
	oscillator = CosGenerator.new()
	oscillator.set_waves([frequency_tuner.frequency_data], 44100)
	audio_player.set_generator(oscillator.next_sample)


func _on_toggled(is_toggled: bool) -> void:
	if is_toggled:
		play()
	else:
		stop()


func _on_frequency_data_changed(new_frequency: FrequencyData) -> void:
	oscillator.update_waves([new_frequency])
	if not button_pressed:
		return
	audio_player.set_generator(oscillator.next_sample)



func play() -> void:
	audio_player.set_generator(oscillator.next_sample)
	audio_player.play()


func stop() -> void:
	audio_player.stop()
