extends Control

@export_subgroup("Signal Generation")
@export var sampling_rate: int = 44100
@export var duration: float = 0.1
@export_subgroup("UI Elements")
@export var waveform_draw: WaveformRenderer

func _on_frequency_data_changed(new_data: Array[FrequencyData]) -> void:
	var samples: PackedFloat32Array = SignalGen.generate_signal(new_data, sampling_rate, duration)
	waveform_draw.draw(samples)