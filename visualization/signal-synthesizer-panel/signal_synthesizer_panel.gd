extends PanelContainer

@export_subgroup("Signal Generation")
@export var sampling_rate: int = 44100
@export var duration: float = 0.1
@export_subgroup("UI Elements")
@export var waveform_draw: WaveFormRenderer
@export var frequency_data_tuners: Array[FrequencyDataTuner] = []
@export var sampling_rate_label: Label
@export var duration_label: Label


func _ready() -> void:
	sampling_rate_label.text = "%d Hz" % sampling_rate
	duration_label.text = "%.1f s" % duration
	for frequency_data_ui in frequency_data_tuners:
		frequency_data_ui.frequency_data_changed.connect(_on_frequency_data_changed)
	_on_frequency_data_changed(null)


func _on_frequency_data_changed(_new_data: FrequencyData) -> void:
	var frequency_data_list: Array[FrequencyData] = []
	for frequency_data_ui in frequency_data_tuners:
		frequency_data_list.append(frequency_data_ui.frequency_data)
	var samples: PackedFloat32Array = SignalGen.generate_signal(frequency_data_list, sampling_rate, duration)
	waveform_draw.draw(samples)