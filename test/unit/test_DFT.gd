extends GutTest

const sampling_rate: int = 44100

func test_DFT() -> void:
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
    var new_samples: PackedFloat32Array = SignalGenerator.GenerateSignal(
        spectrum,
        sampling_rate,
        1.0
    )
    
    assert_eq(samples.size(), new_samples.size())

    for i in range(new_samples.size()):
        assert_almost_eq(new_samples[i], samples[i], 0.1)