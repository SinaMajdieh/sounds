extends Node

const SAMPLING_RATE: int = 44100
const BIN_SIZE: int = 4096

func _ready() -> void:
	var start_time: int = Time.get_ticks_msec()
	var frequencies: Array[FrequencyDataResource] = [
		FrequencyDataResource.Create(172.266, 1.0, 0.0),
		FrequencyDataResource.Create(344.531, 1.0, 0.0),
		FrequencyDataResource.Create(516.797, 1.0, 0.0),
		# FrequencyDataResource.Create(150, 1.0, 0.0),
		# FrequencyDataResource.Create(250, 1.0, 0.0),
		# FrequencyDataResource.Create(350, 1.0, 0.0),
	]
	var samples: PackedFloat32Array = SignalGenerator.GenerateSignalResource(
		frequencies,
		SAMPLING_RATE,
		10.0
	)
	var source_signal: SignalResource = SignalResource.Create(
		samples,
		SAMPLING_RATE
	)

	# Now returns StftResultResource (not Array, not Dictionary)
	var result: StftResultResource = Stft.ComputeResource(
		source_signal,
		BIN_SIZE
	)

	var reconstructed_signal: SignalResource = Stft.ReconstructSignalResource(result)

	print(reconstructed_signal.Samples.slice(0, 30))
	print(source_signal.Samples.slice(0, 30))

	var end_time: int = Time.get_ticks_msec()
	print("Executed in %d ms" % [end_time - start_time])
