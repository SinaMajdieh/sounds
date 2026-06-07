class_name SignalTuner extends Node

@export_subgroup("UI")
@export var play_button: PlaybackButton
@export var frequency_tuner: FrequencyDataTuner
@export var waveform_renderer: WaveformRenderer


func _ready() -> void:
	frequency_tuner.frequency_data_changed.connect(_on_frequency_data_changed)
	_on_frequency_data_changed(frequency_tuner.frequency_data)


func _on_frequency_data_changed(new_data: FrequencyData) -> void:
	var samples: PackedFloat32Array = SignalGen.generate_signal([new_data], 44100, 0.1)
	waveform_renderer.draw(samples)
