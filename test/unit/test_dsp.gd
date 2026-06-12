extends GutTest

const SAMPLING_RATE: int = 4410
const BIN_SIZE: int = 4096


func test_dft() -> void:
    var frequencies: Array[FrequencyDataResource] = [
        FrequencyDataResource.Create(150.0, 1.0, 0.0),
        FrequencyDataResource.Create(250.0, 1.0, 0.0),
        FrequencyDataResource.Create(350.0, 1.0, 0.0),
    ]
    
    # Generate signal from resource frequencies
    var samples: PackedFloat32Array = SignalGenerator.GenerateSignalResource(
        frequencies,
        SAMPLING_RATE,
        1.0
    )

    # Compute DFT → returns Array[FrequencyDataResource]
    var spectrum: Array = Dft.ComputeResource(
        samples,
        SAMPLING_RATE
    )

    # Reconstruct signal from computed spectrum
    var new_samples: PackedFloat32Array = SignalGenerator.GenerateSignalResource(
        spectrum,
        SAMPLING_RATE,
        1.0
    )
    
    assert_eq(samples.size(), new_samples.size())

    for i in range(new_samples.size()):
        assert_almost_eq(new_samples[i], samples[i], 0.1)


func test_stft() -> void:
    var frequencies: Array[FrequencyDataResource] = [
        FrequencyDataResource.Create(172.266, 1.0, 0.0),
        FrequencyDataResource.Create(344.531, 1.0, 0.0),
        FrequencyDataResource.Create(516.797, 1.0, 0.0),
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

    var result: StftResultResource = Stft.ComputeResource(
        source_signal,
        BIN_SIZE
    )

    var reconstructed_signal: SignalResource = Stft.ReconstructSignalResource(result)

    assert_eq(
        source_signal.SampleCount,
        reconstructed_signal.SampleCount
    )

    for i in range(reconstructed_signal.SampleCount):
        assert_almost_eq(
            reconstructed_signal.Samples[i],
            source_signal.Samples[i],
            0.1
        )
