class_name WaveformCache
extends RefCounted

var samples: PackedFloat32Array = PackedFloat32Array()

var mins: PackedFloat32Array = PackedFloat32Array()
var maxs: PackedFloat32Array = PackedFloat32Array()

var max_amplitude: float = 1.0


func set_samples(new_samples: PackedFloat32Array) -> void:
    samples = new_samples

    max_amplitude = 0.0
    for sample in samples:
        max_amplitude = max(max_amplitude, abs(sample))

    if max_amplitude == 0.0:
        max_amplitude = 1.0


func build(columns: int, normalize: bool) -> void:

    if columns <= 0 or samples.is_empty():
        return

    var samples_per_column: float = float(samples.size()) / float(columns)

    mins.resize(columns)
    maxs.resize(columns)

    for x in range(columns):

        var start: int = int(x * samples_per_column)
        var end: int = int((x + 1) * samples_per_column)

        var min_val: float = 1.0
        var max_val: float = -1.0

        for i in range(start, min(end, samples.size())):

            var sample: float = samples[i]

            if normalize:
                sample /= max_amplitude

            min_val = min(min_val, sample)
            max_val = max(max_val, sample)

        mins[x] = min_val
        maxs[x] = max_val
