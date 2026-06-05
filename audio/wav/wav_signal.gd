class_name WavSignal extends Resource

@export var samples: PackedFloat32Array
@export var sample_rate: int

func _init(init_samples: PackedFloat32Array = PackedFloat32Array(), init_sample_rate: int = 44100) -> void:
    samples = init_samples
    sample_rate = init_sample_rate