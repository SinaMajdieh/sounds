extends Node

@export var frequency_data_ui: FrequencyDataTuner
@export var waveform_renderer: WaveformRenderer


func _ready() -> void:
	frequency_data_ui.frequency_data_changed.connect(_on_frequency_data_changed)
	_on_frequency_data_changed(frequency_data_ui.frequency_data)


func _on_frequency_data_changed(new_data: FrequencyData) -> void:
	var samples: PackedFloat32Array = SignalGen.generate_signal([new_data], 44100, 0.1)
	waveform_renderer.draw(samples)
