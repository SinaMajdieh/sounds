class_name FrequencyDataTuner extends PanelContainer

signal frequency_data_changed(new_data: FrequencyData)

@export_subgroup("Frequency Data")
@export var frequency_spinbox: SpinBox
@export var amplitude_spinbox: SpinBox
@export var phase_spinbox: SpinBox

var frequency_data: FrequencyData = FrequencyData.new(150, 10.0, 0)


func _ready() -> void:
	frequency_spinbox.value = frequency_data.frequency
	amplitude_spinbox.value = frequency_data.amplitude
	phase_spinbox.value = frequency_data.phase

	frequency_spinbox.value_changed.connect(_on_frequency_changed)
	amplitude_spinbox.value_changed.connect(_on_amplitude_changed)
	phase_spinbox.value_changed.connect(_on_phase_changed)


func _on_frequency_changed(value: float) -> void:
	frequency_data.frequency = value
	frequency_data_changed.emit(frequency_data)


func _on_amplitude_changed(value: float) -> void:
	frequency_data.amplitude = value
	frequency_data_changed.emit(frequency_data)


func _on_phase_changed(value: float) -> void:
	frequency_data.phase = value
	frequency_data_changed.emit(frequency_data)
