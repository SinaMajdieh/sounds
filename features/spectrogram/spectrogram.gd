extends Control

@export_category("Elements")
@export var viewer: TextureRect

@export_category("Data")
@export var num_segments: int = 1

@export_global_file("*.wav") var wav_path: String

var source_signal: SignalResource
var stft: StftResultResource


func _ready() -> void:
    open_wav()
    apply_stft()
    viewer.texture = Spectrogram.GenerateTexture(stft)


func open_wav() -> void:
    if wav_path.is_empty():
        return

    var wav_file: FileAccess = FileAccess.open(wav_path, FileAccess.READ)
    if not wav_file:
        push_error(FileAccess.get_open_error())
        return

    var wav_signal = WavReader.read(wav_file)
    source_signal = SignalResource.Create(
        wav_signal.samples,
        wav_signal.sample_rate
    )


func apply_stft() -> void:
    if not source_signal:
        return

    num_segments = max(1, num_segments)

    var samples_per_segment: int = ceili(
        source_signal.SampleCount / float(num_segments)
    )

    stft = Stft.ComputeResource(source_signal, samples_per_segment)