extends Node

@export var sampling_rate: int = 21

func _ready() -> void:
	var frequencies: Array[FrequencyData] = [
		FrequencyData.new(1, 1, 0),
		FrequencyData.new(5, 1, 0),
		FrequencyData.new(10, 1, 0),
	]
	var samples: PackedFloat32Array = SignalGenerator.GenerateSignal(
		FrequencyData.marshall_to_array(frequencies),
		sampling_rate,
		1.0
	)

	var spectrum: PackedFloat32Array = DFT.Compute(samples, sampling_rate)
	print(spectrum.size())
	var new_samples: PackedFloat32Array = SignalGenerator.GenerateSignal(
		spectrum,
		sampling_rate,
		1.0
	)
	print(new_samples.slice(0, 10))
	print(samples.slice(0, 10))
