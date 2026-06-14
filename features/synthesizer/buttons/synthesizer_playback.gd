extends PlaybackButton

var oscillator: CosGenerator


func _ready() -> void:
	super()
	oscillator = CosGenerator.new()
	audio_player.set_generator(oscillator.next_sample)


func _on_toggled(is_toggled: bool) -> void:
	if is_toggled:
		play()
	else:
		stop()


func _on_frequency_data_changed(new_frequencies: Array[FrequencyData]) -> void:
	oscillator.update_waves(new_frequencies)
	if not button_pressed:
		return
	audio_player.set_generator(oscillator.next_sample)


func play() -> void:
	audio_player.set_generator(oscillator.next_sample)
	audio_player.play()


func stop() -> void:
	audio_player.stop()
