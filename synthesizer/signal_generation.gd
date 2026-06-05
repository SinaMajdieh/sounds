class_name SignalGen

static func generate_signal(
    waves: Array[FrequencyData], 
    sample_rate: int, 
    duration: float
) -> PackedFloat32Array:
    var num_samples: int = int(sample_rate * duration)
    var samples: PackedFloat32Array = PackedFloat32Array()
    samples.resize(num_samples)

    for i in num_samples:
        var time: float = i / float(num_samples) * duration
        for wave: FrequencyData in waves:
            var angle: float = time * TAU * wave.frequency + wave.phase
            samples[i] += cos(angle) * wave.amplitude

    return samples