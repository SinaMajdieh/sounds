class_name SignalGen

static func generate_signal(
    waves: Array[FrequencyData], 
    sample_rate: int, 
    duration: float
) -> PackedFloat32Array:
    var num_samples: int = int(sample_rate * duration)
    var samples: PackedFloat32Array = PackedFloat32Array()
    samples.resize(num_samples)

    var phases: PackedFloat32Array = PackedFloat32Array()
    var phase_steps: PackedFloat32Array = PackedFloat32Array()

    for wave in waves:
        phases.append(wave.phase)
        phase_steps.append(TAU * wave.frequency / sample_rate)

    for i in range(num_samples):
        var value: float = 0.0
        for j in range(waves.size()):
            value += cos(phases[j]) * waves[j].amplitude
            phases[j] += phase_steps[j]
        samples[i] = value
    return samples