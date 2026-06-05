class_name FrequencyData extends Resource

@export var frequency: float
@export var amplitude: float
@export var phase: float


func _init(init_frequency:int, init_amplitude: float, init_phase: float) -> void:
	frequency = init_frequency
	amplitude = init_amplitude
	phase = init_phase


func _to_string() -> String:
	return "Frequency: %f, Amplitude: %f, Phase: %f" % [frequency, amplitude, phase]