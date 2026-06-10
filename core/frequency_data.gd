class_name FrequencyData extends Resource

@export var frequency: float
@export var amplitude: float
@export var phase: float


func _init(init_frequency:float, init_amplitude: float, init_phase: float) -> void:
	frequency = init_frequency
	amplitude = init_amplitude
	phase = init_phase


static func marshall_to_array(data: Array[FrequencyData]) -> PackedFloat32Array:
	var result: PackedFloat32Array = PackedFloat32Array()
	result.resize(data.size() * 3)
	
	for i in range(data.size()):
		var base_index: int = i * 3
		result[base_index] = data[i].frequency
		result[base_index + 1] = data[i].amplitude
		result[base_index + 2] = data[i].phase

	return result


static func unmarshall_from_array(data: PackedFloat32Array) -> Array[FrequencyData]:
	if data.size() % 3 != 0:
		push_error("Cannot unmarshall to Array[FrequencyData], data size isn't dividable by 3")
		return []
	
	var result: Array[FrequencyData] = []
	result.resize(int(data.size() / 3.0))

	for i: int in range(result.size()):
		var base_index: int = i * 3
		var frequency_data: FrequencyData = FrequencyData.new(
			data[base_index],
			data[base_index + 1],
			data[base_index + 2],
		)
		result[i] = frequency_data
	
	return result


func _to_string() -> String:
	return "Frequency: %f, Amplitude: %f, Phase: %f" % [frequency, amplitude, phase]
