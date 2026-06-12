class_name CosGenerator
extends Generator

var waves: Array[FrequencyData] = []
var phases: PackedFloat32Array = PackedFloat32Array()
var phase_steps: PackedFloat32Array = PackedFloat32Array()

var sample_rate: float = 44100.0


func set_waves(new_waves: Array[FrequencyData], new_sample_rate: int) -> void:
    waves = new_waves
    sample_rate = new_sample_rate

    phases.resize(waves.size())
    phase_steps.resize(waves.size())

    for i in range(waves.size()):
        phases[i] = waves[i].phase
        phase_steps[i] = TAU * waves[i].frequency / sample_rate


func update_waves(new_waves: Array[FrequencyData]) -> void:
    waves = new_waves

    if phases.size() != waves.size():
        phases.resize(waves.size())
        phase_steps.resize(waves.size())

    for i in range(waves.size()):
        phase_steps[i] = TAU * waves[i].frequency / sample_rate


func next_sample() -> float:
    var value: float = 0.0

    for i in range(waves.size()):
        value += cos(phases[i]) * waves[i].amplitude

        phases[i] += phase_steps[i]

        if phases[i] > TAU:
            phases[i] -= TAU

    return value
